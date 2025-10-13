package com.hilgo.rotax.service;

import com.hilgo.rotax.dto.DriverStatusUpdateRequest;
import com.hilgo.rotax.dto.LocationDTO;
import com.hilgo.rotax.dto.ProfileUpdateRequestDTO;
import com.hilgo.rotax.dto.UserDTO;
import com.hilgo.rotax.entity.Cargo;
import com.hilgo.rotax.entity.Driver;
import com.hilgo.rotax.entity.Location;
import com.hilgo.rotax.enums.CarType;
import com.hilgo.rotax.enums.CargoSituation;
import com.hilgo.rotax.enums.DriverStatus;
import com.hilgo.rotax.exception.OperationNotAllowedException;
import com.hilgo.rotax.repository.CargoRepository;
import com.hilgo.rotax.repository.DriverRepository;
import com.hilgo.rotax.repository.LocationRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.multipart.MultipartFile;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class DriverServiceTest {

    @Mock
    private DriverRepository driverRepository;

    @Mock
    private LocationRepository locationRepository;

    @Mock
    private CargoRepository cargoRepository;

    @Mock
    private AuthenticationService authenticationService;

    @Mock
    private FileStorageService fileStorageService;

    @InjectMocks
    private DriverService driverService;

    private Driver testDriver;

    @BeforeEach
    void setUp() {
        testDriver = new Driver();
        testDriver.setId(1L);
        testDriver.setUsername("testdriver");
        testDriver.setFirstName("Test");
        testDriver.setLastName("Driver");

        // Mock SecurityContext to simulate a logged-in user
        SecurityContext securityContext = mock(SecurityContext.class);
        when(securityContext.getAuthentication()).thenReturn(new UsernamePasswordAuthenticationToken(testDriver.getUsername(), "password"));
        SecurityContextHolder.setContext(securityContext);

        when(driverRepository.findByUsername(testDriver.getUsername())).thenReturn(Optional.of(testDriver));
    }

    @Test
    void updateDriverStatus_ShouldUpdateStatusAndLocation() {
        // Arrange
        LocationDTO locationDTO = new LocationDTO();
        locationDTO.setLatitude(41.0);
        locationDTO.setLongitude(29.0);

        DriverStatusUpdateRequest request = new DriverStatusUpdateRequest();
        request.setStatus(DriverStatus.ACTIVE);
        request.setLocation(locationDTO);

        // Act
        driverService.updateDriverStatus(request);

        // Assert
        verify(locationRepository, times(1)).save(any(Location.class));
        verify(driverRepository, times(1)).save(testDriver);
        assertEquals(DriverStatus.ACTIVE, testDriver.getDriverStatus());
        assertNotNull(testDriver.getLocation());
        assertEquals(41.0, testDriver.getLocation().getLatitude());
    }

    @Test
    void updateProfile_ShouldUpdateProfileFields() {
        // Arrange
        ProfileUpdateRequestDTO request = new ProfileUpdateRequestDTO();
        request.setFirstName("UpdatedName");
        request.setCarType(CarType.HATCHBACK);

        when(authenticationService.convertToDTO(any(Driver.class))).thenReturn(new UserDTO());

        // Act
        driverService.updateProfile(request);

        // Assert
        verify(driverRepository, times(1)).save(testDriver);
        assertEquals("UpdatedName", testDriver.getFirstName());
        assertEquals(CarType.HATCHBACK, testDriver.getCarType());
    }

    @Test
    void updateProfilePicture_ShouldStoreFileAndUpdateUser() {
        // Arrange
        MultipartFile mockFile = mock(MultipartFile.class);
        String fileUrl = "http://localhost/uploads/test.jpg";

        when(fileStorageService.storeFile(mockFile)).thenReturn(fileUrl);
        when(authenticationService.convertToDTO(any(Driver.class))).thenReturn(new UserDTO());

        // Act
        driverService.updateProfilePicture(mockFile);

        // Assert
        verify(fileStorageService, times(1)).storeFile(mockFile);
        verify(driverRepository, times(1)).save(testDriver);
        assertEquals(fileUrl, testDriver.getProfilePictureUrl());
    }

    @Test
    void acceptOffer_ShouldAssignCargoToDriver() {
        // Arrange
        Cargo cargo = new Cargo();
        cargo.setId(10L);
        cargo.setCargoSituation(CargoSituation.CREATED);

        when(cargoRepository.findById(10L)).thenReturn(Optional.of(cargo));

        // Act
        driverService.acceptOffer(10L);

        // Assert
        verify(cargoRepository, times(1)).save(cargo);
        assertEquals(CargoSituation.ASSIGNED, cargo.getCargoSituation());
        assertEquals(testDriver, cargo.getDriver());
    }

    @Test
    void acceptOffer_ShouldThrowException_WhenCargoNotAvailable() {
        // Arrange
        Cargo cargo = new Cargo();
        cargo.setId(10L);
        cargo.setCargoSituation(CargoSituation.ASSIGNED); // Not available

        when(cargoRepository.findById(10L)).thenReturn(Optional.of(cargo));

        // Act & Assert
        assertThrows(OperationNotAllowedException.class, () -> {
            driverService.acceptOffer(10L);
        });
    }

    @Test
    void updateCargoStatus_ShouldUpdateStatusCorrectly() {
        // Arrange
        Cargo cargo = new Cargo();
        cargo.setDriver(testDriver); // Cargo belongs to the current driver
        cargo.setCargoSituation(CargoSituation.ASSIGNED);

        when(cargoRepository.findById(anyLong())).thenReturn(Optional.of(cargo));

        // Act
        driverService.updateCargoStatus(10L, CargoSituation.PICKED_UP);

        // Assert
        verify(cargoRepository, times(1)).save(cargo);
        assertEquals(CargoSituation.PICKED_UP, cargo.getCargoSituation());
        assertNotNull(cargo.getTakingTime());
    }
}