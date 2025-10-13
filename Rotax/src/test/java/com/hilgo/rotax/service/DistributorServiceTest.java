package com.hilgo.rotax.service;

import com.hilgo.rotax.dto.AddressDTO;
import com.hilgo.rotax.dto.CreateCargoRequest;
import com.hilgo.rotax.dto.LocationDTO;
import com.hilgo.rotax.dto.MeasureDTO;
import com.hilgo.rotax.dto.ProfileUpdateRequestDTO;
import com.hilgo.rotax.entity.Cargo;
import com.hilgo.rotax.entity.Distributor;
import com.hilgo.rotax.enums.CargoSituation;
import com.hilgo.rotax.exception.OperationNotAllowedException;
import com.hilgo.rotax.exception.UserNotActiveException;
import com.hilgo.rotax.repository.CargoRepository;
import com.hilgo.rotax.repository.DistributorRepository;
import com.hilgo.rotax.repository.LocationRepository;
import com.hilgo.rotax.repository.MeasureRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class DistributorServiceTest {

    @Mock
    private DistributorRepository distributorRepository;
    @Mock
    private CargoRepository cargoRepository;
    @Mock
    private LocationRepository locationRepository;
    @Mock
    private MeasureRepository measureRepository;
    @Mock

    @InjectMocks
    private DistributorService distributorService;

    private Distributor testDistributor;

    @BeforeEach
    void setUp() {
        testDistributor = new Distributor();
        testDistributor.setId(1L);
        testDistributor.setUsername("testdistributor");
        testDistributor.setFirstName("Test");
        testDistributor.setLastName("Distributor");
        testDistributor.setEnabled(true); // Başarılı senaryolar için aktif

        // Mock SecurityContext to simulate a logged-in user
        SecurityContext securityContext = mock(SecurityContext.class);
        when(securityContext.getAuthentication()).thenReturn(new UsernamePasswordAuthenticationToken(testDistributor.getUsername(), "password"));
        SecurityContextHolder.setContext(securityContext);

        when(distributorRepository.findByUsername(testDistributor.getUsername())).thenReturn(Optional.of(testDistributor));
    }

    @Test
    void createCargo_ShouldCreateAndSaveCargo_WhenUserIsActive() {
        // Arrange
        CreateCargoRequest request = new CreateCargoRequest();
        request.setSelfLocation(new LocationDTO());
        request.setTargetLocation(new LocationDTO());
        request.setMeasure(new MeasureDTO());

        when(cargoRepository.save(any(Cargo.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        distributorService.createCargo(request);

        // Assert
        verify(locationRepository, times(2)).save(any());
        verify(measureRepository, times(1)).save(any());
        verify(cargoRepository, times(1)).save(any(Cargo.class));
    }

    @Test
    void createCargo_ShouldThrowException_WhenUserIsNotActive() {
        // Arrange
        testDistributor.setEnabled(false); // Kullanıcıyı pasif yap
        CreateCargoRequest request = new CreateCargoRequest();

        // Act & Assert
        assertThrows(UserNotActiveException.class, () -> {
            distributorService.createCargo(request);
        });
        verify(cargoRepository, never()).save(any());
    }

    @Test
    void updateProfile_ShouldUpdateAddress_WhenAddressIsProvided() {
        // Arrange
        ProfileUpdateRequestDTO request = new ProfileUpdateRequestDTO();
        com.hilgo.rotax.dto.LocationDTO locationDTO = new LocationDTO();
        locationDTO.setCity("Ankara");
        request.setLocationDTO(locationDTO);

        // Act
        distributorService.updateProfile(request);

        // Assert
        verify(distributorRepository, times(1)).save(testDistributor);
        assertNotNull(testDistributor.getLocation());
        assertEquals("Ankara", testDistributor.getLocation().getCity());
    }

    @Test
    void cancelCargo_ShouldSetCargoStatusToCancelled() {
        // Arrange
        Cargo cargo = new Cargo();
        cargo.setId(10L);
        cargo.setDistributor(testDistributor);
        cargo.setCargoSituation(CargoSituation.CREATED);

        when(cargoRepository.findById(10L)).thenReturn(Optional.of(cargo));
        when(cargoRepository.save(any(Cargo.class))).thenReturn(cargo);

        // Act
        distributorService.cancelCargo(10L);

        // Assert
        verify(cargoRepository, times(1)).save(cargo);
        assertEquals(CargoSituation.CANCELLED, cargo.getCargoSituation());
    }

    @Test
    void cancelCargo_ShouldThrowException_WhenCargoIsNotCancellable() {
        // Arrange
        Cargo cargo = new Cargo();
        cargo.setId(10L);
        cargo.setDistributor(testDistributor);
        cargo.setCargoSituation(CargoSituation.DELIVERED); // İptal edilemez durumda

        when(cargoRepository.findById(10L)).thenReturn(Optional.of(cargo));

        // Act & Assert
        assertThrows(OperationNotAllowedException.class, () -> {
            distributorService.cancelCargo(10L);
        });
    }
}