package com.hilgo.rotax.service;

import com.hilgo.rotax.dto.*;
import com.hilgo.rotax.entity.Cargo;
import com.hilgo.rotax.entity.Driver;
import com.hilgo.rotax.entity.Location;
import com.hilgo.rotax.enums.CargoSituation;
import com.hilgo.rotax.enums.DriverStatus;
import com.hilgo.rotax.repository.CargoRepository;
import com.hilgo.rotax.repository.DriverRepository;
import com.hilgo.rotax.repository.LocationRepository;
import com.hilgo.rotax.repository.ReviewRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DriverService {

    private final DriverRepository driverRepository;
    private final LocationRepository locationRepository;
    private final CargoRepository cargoRepository;
    private final ReviewRepository reviewRepository;

    public Driver getCurrentDriver() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();
        return driverRepository.findByUsername(username)
                .orElseThrow(() -> new com.hilgo.rotax.exception.ResourceNotFoundException("Driver", "username", username));
    }

    @Transactional
    public void updateDriverStatus(DriverStatusUpdateRequest request) {
        Driver driver = getCurrentDriver();
        
        // Update driver status
        driver.setDriverStatus(request.getStatus());
        
        // Update driver location
        Location location = driver.getLocation();
        if (location == null) {
            location = new Location();
        }
        
        location.setLatitude(request.getLocation().getLatitude());
        location.setLongitude(request.getLocation().getLongitude());
        location.setAddress(request.getLocation().getAddress());
        location.setCity(request.getLocation().getCity());
        location.setDistrict(request.getLocation().getDistrict());
        location.setPostalCode(request.getLocation().getPostalCode());
        
        locationRepository.save(location);
        driver.setLocation(location);
        driverRepository.save(driver);
    }

    public DriverDashboardResponse getDriverDashboard() {
        Driver driver = getCurrentDriver();
        
        // Get driver's cargos
        List<Cargo> allCargos = cargoRepository.findByDriver(driver);
        List<Cargo> activeCargos = allCargos.stream()
                .filter(cargo -> cargo.getCargoSituation() == CargoSituation.ASSIGNED || 
                                cargo.getCargoSituation() == CargoSituation.PICKED_UP)
                .collect(Collectors.toList());
        
        List<Cargo> recentCargos = allCargos.stream()
                .filter(cargo -> cargo.getCargoSituation() == CargoSituation.DELIVERED)
                .sorted((c1, c2) -> c2.getUpdatedAt().compareTo(c1.getUpdatedAt()))
                .limit(5)
                .collect(Collectors.toList());
        
        // Get driver's average rating
        Double averageRating = reviewRepository.getAverageRatingForDriver(driver.getId());
        if (averageRating == null) {
            averageRating = 0.0;
        }
        
        return DriverDashboardResponse.builder()
                .driverId(driver.getId())
                .driverName(driver.getFirstName() + " " + driver.getLastName())
                .averageRating(averageRating)
                .totalDeliveries((int) allCargos.stream()
                        .filter(cargo -> cargo.getCargoSituation() == CargoSituation.DELIVERED)
                        .count())
                .activeDeliveries(activeCargos.size())
                .currentCargos(activeCargos.stream().map(this::mapToCargoDTO).collect(Collectors.toList()))
                .recentCargos(recentCargos.stream().map(this::mapToCargoDTO).collect(Collectors.toList()))
                .build();
    }

    public List<CargoOfferDTO> getAvailableOffers() {
        Driver driver = getCurrentDriver();
        
        // Only active drivers can see offers
        if (driver.getDriverStatus() != DriverStatus.ACTIVE && 
            driver.getDriverStatus() != DriverStatus.DESTINATION_BASED) {
            return new ArrayList<>();
        }
        
        // Get driver's location
        Location driverLocation = driver.getLocation();
        if (driverLocation == null) {
            return new ArrayList<>();
        }
        
        // Find nearby cargos (within 10km)
        List<Cargo> nearbyCargos = cargoRepository.findNearbyCargos(
                CargoSituation.CREATED, 
                driverLocation.getLatitude(), 
                driverLocation.getLongitude(), 
                10000.0);
        
        return nearbyCargos.stream()
                .map(cargo -> {
                    // Calculate distance to pickup
                    double distanceToPickup = calculateDistance(
                            driverLocation.getLatitude(), 
                            driverLocation.getLongitude(),
                            cargo.getSelfLocation().getLatitude(),
                            cargo.getSelfLocation().getLongitude());
                    
                    // Calculate total distance (pickup to delivery)
                    double totalDistance = calculateDistance(
                            cargo.getSelfLocation().getLatitude(),
                            cargo.getSelfLocation().getLongitude(),
                            cargo.getTargetLocation().getLatitude(),
                            cargo.getTargetLocation().getLongitude());
                    
                    // Calculate estimated earning (based on distance)
                    double estimatedEarning = calculateEarning(totalDistance);
                    
                    return CargoOfferDTO.builder()
                            .cargoId(cargo.getId())
                            .pickupLocation(mapToLocationDTO(cargo.getSelfLocation()))
                            .deliveryLocation(mapToLocationDTO(cargo.getTargetLocation()))
                            .distanceToPickup(distanceToPickup)
                            .totalDistance(totalDistance)
                            .estimatedEarning(estimatedEarning)
                            .measure(mapToMeasureDTO(cargo.getMeasure()))
                            .distributorName(cargo.getDistributor().getFirstName() + " " + cargo.getDistributor().getLastName())
                            .build();
                })
                .collect(Collectors.toList());
    }

    @Transactional
    public CargoDTO acceptOffer(Long cargoId) {
        Driver driver = getCurrentDriver();
        
        Cargo cargo = cargoRepository.findById(cargoId)
                .orElseThrow(() -> new RuntimeException("Cargo not found"));
        
        // Check if cargo is available
        if (cargo.getCargoSituation() != CargoSituation.CREATED) {
            throw new RuntimeException("Cargo is not available for acceptance");
        }
        
        // Assign cargo to driver
        cargo.setDriver(driver);
        cargo.setCargoSituation(CargoSituation.ASSIGNED);
        cargo = cargoRepository.save(cargo);
        
        return mapToCargoDTO(cargo);
    }

    @Transactional
    public CargoDTO updateCargoStatus(Long cargoId, CargoSituation newStatus) {
        Driver driver = getCurrentDriver();
        
        Cargo cargo = cargoRepository.findById(cargoId)
                .orElseThrow(() -> new RuntimeException("Cargo not found"));
        
        // Check if cargo belongs to driver
        if (!cargo.getDriver().getId().equals(driver.getId())) {
            throw new RuntimeException("Cargo does not belong to this driver");
        }
        
        // Validate status transition
        validateStatusTransition(cargo.getCargoSituation(), newStatus);
        
        // Update cargo status
        cargo.setCargoSituation(newStatus);
        
        // Set timestamps based on status
        if (newStatus == CargoSituation.PICKED_UP) {
            cargo.setTakingTime(LocalDateTime.now());
        } else if (newStatus == CargoSituation.DELIVERED) {
            cargo.setDeliveredTime(LocalDateTime.now());
        }
        
        cargo = cargoRepository.save(cargo);
        
        return mapToCargoDTO(cargo);
    }

    private void validateStatusTransition(CargoSituation currentStatus, CargoSituation newStatus) {
        if (currentStatus == CargoSituation.ASSIGNED && newStatus == CargoSituation.PICKED_UP) {
            return;
        }
        
        if (currentStatus == CargoSituation.PICKED_UP && newStatus == CargoSituation.DELIVERED) {
            return;
        }
        
        throw new RuntimeException("Invalid status transition from " + currentStatus + " to " + newStatus);
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

    private MeasureDTO mapToMeasureDTO(com.hilgo.rotax.entity.Measure measure) {
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

    // Helper method to calculate distance between two points using Haversine formula
    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371; // Radius of the earth in km
        
        double latDistance = Math.toRadians(lat2 - lat1);
        double lonDistance = Math.toRadians(lon2 - lon1);
        
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
        
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        
        return R * c; // Distance in km
    }

    // Helper method to calculate earning based on distance
    private double calculateEarning(double distance) {
        // Base fare + per km rate
        return 20.0 + (distance * 2.5);
    }
}