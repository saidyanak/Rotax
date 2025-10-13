package com.hilgo.rotax.service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.hilgo.rotax.dto.CargoDTO;
import com.hilgo.rotax.dto.CreateCargoRequest;
import com.hilgo.rotax.dto.DistributorDashboardResponse;
import com.hilgo.rotax.dto.LocationDTO;
import com.hilgo.rotax.dto.MeasureDTO;
import com.hilgo.rotax.dto.ProfileUpdateRequestDTO;
import com.hilgo.rotax.dto.UserDTO;
import com.hilgo.rotax.entity.Cargo;
import com.hilgo.rotax.entity.Distributor;
import com.hilgo.rotax.entity.Location;
import com.hilgo.rotax.entity.Measure;
import com.hilgo.rotax.enums.CargoSituation;
import com.hilgo.rotax.exception.OperationNotAllowedException;
import com.hilgo.rotax.exception.ResourceNotFoundException;
import com.hilgo.rotax.exception.UserNotActiveException;
import com.hilgo.rotax.repository.CargoRepository;
import com.hilgo.rotax.repository.DistributorRepository;
import com.hilgo.rotax.repository.LocationRepository;
import com.hilgo.rotax.repository.MeasureRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class DistributorService {

    private final DistributorRepository distributorRepository;
    private final CargoRepository cargoRepository;
    private final LocationRepository locationRepository;
    private final MeasureRepository measureRepository;
    private final FileStorageService fileStorageService;
    private final AuthenticationService authenticationService;

    public Distributor getCurrentDistributor() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();
        return distributorRepository.findByUsername(username)
                .orElseThrow(() -> new com.hilgo.rotax.exception.ResourceNotFoundException("Distributor", "username", username));
    }

    public DistributorDashboardResponse getDistributorDashboard() {
        Distributor distributor = getCurrentDistributor();
        
        // Get distributor's cargos
        List<Cargo> allCargos = cargoRepository.findByDistributor(distributor);
        
        List<Cargo> activeCargos = allCargos.stream()
                .filter(cargo -> cargo.getCargoSituation() == CargoSituation.CREATED || 
                                cargo.getCargoSituation() == CargoSituation.ASSIGNED || 
                                cargo.getCargoSituation() == CargoSituation.PICKED_UP)
                .collect(Collectors.toList());
        
        List<Cargo> recentCargos = allCargos.stream()
                .filter(cargo -> cargo.getCargoSituation() == CargoSituation.DELIVERED)
                .sorted((c1, c2) -> c2.getUpdatedAt().compareTo(c1.getUpdatedAt()))
                .limit(5)
                .collect(Collectors.toList());
        
        return DistributorDashboardResponse.builder()
                .distributorId(distributor.getId())
                .distributorName(distributor.getFirstName() + " " + distributor.getLastName())
                .totalCargos(allCargos.size())
                .activeCargos(activeCargos.size())
                .deliveredCargos((int) allCargos.stream()
                        .filter(cargo -> cargo.getCargoSituation() == CargoSituation.DELIVERED)
                        .count())
                .currentCargos(activeCargos.stream().map(this::mapToCargoDTO).collect(Collectors.toList()))
                .recentCargos(recentCargos.stream().map(this::mapToCargoDTO).collect(Collectors.toList()))
                .build();
    }

    @Transactional
    public CargoDTO createCargo(CreateCargoRequest request) {
        Distributor distributor = getCurrentDistributor();

        // Kullanıcı aktif değilse kargo oluşturmasını engelle
        if (!distributor.getEnabled()) {
            throw new UserNotActiveException("Hesabınız henüz onaylanmamıştır. Kargo oluşturamazsınız.");
        }
        
        // Create and save locations
        Location selfLocation = getTargetLocation(request.getSelfLocation());
        locationRepository.save(selfLocation);

        Location targetLocation = getTargetLocation(request.getTargetLocation());
        locationRepository.save(targetLocation);
        
        // Create and save measure
        Measure measure = new Measure();
        measure.setWeight(request.getMeasure().getWeight());
        measure.setWidth(request.getMeasure().getWidth());
        measure.setHeight(request.getMeasure().getHeight());
        measure.setLength(request.getMeasure().getLength());
        measure.setSize(request.getMeasure().getSize());
        measureRepository.save(measure);
        
        // Create cargo
        Cargo cargo = Cargo.builder()
                .selfLocation(selfLocation)
                .targetLocation(targetLocation)
                .measure(measure)
                .cargoSituation(CargoSituation.CREATED)
                .phoneNumber(request.getPhoneNumber())
                .description(request.getDescription())
                .distributor(distributor)
                .verificationCode(generateVerificationCode())
                .build();
        
        cargo = cargoRepository.save(cargo);
        
        return mapToCargoDTO(cargo);
    }

    private static Location getTargetLocation(LocationDTO request) {
        Location targetLocation = new Location();
        targetLocation.setLatitude(request.getLatitude());
        targetLocation.setLongitude(request.getLongitude());
        targetLocation.setAddress(request.getAddress());
        targetLocation.setCity(request.getCity());
        targetLocation.setDistrict(request.getDistrict());
        targetLocation.setPostalCode(request.getPostalCode());
        return targetLocation;
    }

    @Transactional
    public UserDTO updateProfile(ProfileUpdateRequestDTO request) {
        Distributor distributor = getCurrentDistributor();

        // DTO'dan gelen ve null/boş olmayan alanları güncelle
        if (request.getFirstName() != null && !request.getFirstName().isBlank()) {
            distributor.setFirstName(request.getFirstName());
        }
        if (request.getLastName() != null && !request.getLastName().isBlank()) {
            distributor.setLastName(request.getLastName());
        }
        if (request.getPhoneNumber() != null) {
            distributor.setPhoneNumber(request.getPhoneNumber());
        }

        // Adres bilgilerini güncelle
        if (request.getLocationDTO() != null) {
            LocationDTO locationDTO = request.getLocationDTO();
            Location location = distributor.getLocation();
            if (location == null) {
                location = new Location();
                distributor.setLocation(location);
            }
            // Adres alanlarını DTO'dan gelen verilerle güncelle
            location.setLatitude(locationDTO.getLatitude());
            location.setLongitude(locationDTO.getLongitude());
            location.setAddress(locationDTO.getAddress());
            location.setDistrict(locationDTO.getDistrict());
            location.setCity(locationDTO.getCity());
            location.setPostalCode(locationDTO.getPostalCode());
        }

        // Not: VKN gibi hassas veya değişmemesi gereken alanlar burada güncellenmez.

        Distributor updatedDistributor = distributorRepository.save(distributor);
        log.info("Dağıtıcı profili güncellendi: {}", updatedDistributor.getUsername());

        // Güncellenmiş kullanıcıyı standart bir DTO'ya çevirip döndür
        return authenticationService.convertToDTO(updatedDistributor);
    }

    @Transactional
    public UserDTO updateProfilePicture(MultipartFile file) {
        Distributor distributor = getCurrentDistributor();

        String fileUrl = fileStorageService.storeFile(file);
        distributor.setProfilePictureUrl(fileUrl);

        Distributor updatedDistributor = distributorRepository.save(distributor);
        log.info("Dağıtıcı profil resmi güncellendi: {}", distributor.getUsername());

        return authenticationService.convertToDTO(updatedDistributor);
    }

    public List<CargoDTO> getAllCargos() {
        Distributor distributor = getCurrentDistributor();
        
        List<Cargo> cargos = cargoRepository.findByDistributor(distributor);
        
        return cargos.stream()
                .map(this::mapToCargoDTO)
                .collect(Collectors.toList());
    }

    public CargoDTO getCargoById(Long cargoId) {
        Distributor distributor = getCurrentDistributor();
        
        Cargo cargo = cargoRepository.findById(cargoId)
                .orElseThrow(() -> new ResourceNotFoundException("Cargo", "id", cargoId));
        
        // Check if cargo belongs to distributor
        if (!cargo.getDistributor().getId().equals(distributor.getId())) {
            throw new OperationNotAllowedException("Bu kargoyu görüntüleme yetkiniz yok.");
        }
        
        return mapToCargoDTO(cargo);
    }

    @Transactional
    public CargoDTO cancelCargo(Long cargoId) {
        Distributor distributor = getCurrentDistributor();
        
        Cargo cargo = cargoRepository.findById(cargoId)
                .orElseThrow(() -> new ResourceNotFoundException("Cargo", "id", cargoId));
        
        // Check if cargo belongs to distributor
        if (!cargo.getDistributor().getId().equals(distributor.getId())) {
            throw new OperationNotAllowedException("Bu kargoyu iptal etme yetkiniz yok.");
        }
        
        // Check if cargo can be cancelled
        if (cargo.getCargoSituation() != CargoSituation.CREATED && 
            cargo.getCargoSituation() != CargoSituation.ASSIGNED) {
            throw new OperationNotAllowedException("Kargo '" + cargo.getCargoSituation() + "' durumundayken iptal edilemez.");
        }
        
        cargo.setCargoSituation(CargoSituation.CANCELLED);
        cargo = cargoRepository.save(cargo);
        
        return mapToCargoDTO(cargo);
    }

    private CargoDTO mapToCargoDTO(Cargo cargo) {
        return CargoDTO.builder()
                .id(cargo.getId())
                .selfLocation(mapToLocationDTO(cargo.getSelfLocation()))
                .targetLocation(mapToLocationDTO(cargo.getTargetLocation()))
                .measure(mapToMeasureDTO(cargo.getMeasure()))
                .cargoSituation(cargo.getCargoSituation())
                .phoneNumber(cargo.getPhoneNumber())
                .description(cargo.getDescription())
                .takingTime(cargo.getTakingTime())
                .deliveredTime(cargo.getDeliveredTime())
                .createdAt(cargo.getCreatedAt())
                .updatedAt(cargo.getUpdatedAt())
                .distributorId(cargo.getDistributor().getId())
                .distributorName(cargo.getDistributor().getFirstName() + " " + cargo.getDistributor().getLastName())
                .driverId(cargo.getDriver() != null ? cargo.getDriver().getId() : null)
                .driverName(cargo.getDriver() != null ? 
                        cargo.getDriver().getFirstName() + " " + cargo.getDriver().getLastName() : null)
                .build();
    }

    private LocationDTO mapToLocationDTO(Location location) {
        if (location == null) {
            return null;
        }
        
        return LocationDTO.builder()
                .latitude(location.getLatitude())
                .longitude(location.getLongitude())
                .address(location.getAddress())
                .city(location.getCity())
                .district(location.getDistrict())
                .postalCode(location.getPostalCode())
                .build();
    }

    private MeasureDTO mapToMeasureDTO(Measure measure) {
        if (measure == null) {
            return null;
        }
        
        return MeasureDTO.builder()
                .weight(measure.getWeight())
                .width(measure.getWidth())
                .height(measure.getHeight())
                .length(measure.getLength())
                .size(measure.getSize())
                .build();
    }

    private String generateVerificationCode() {
        // Generate a random 8-character code
        return UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
}