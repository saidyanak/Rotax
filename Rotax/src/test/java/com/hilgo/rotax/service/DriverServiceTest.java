package com.hilgo.rotax.service;

import com.hilgo.rotax.BaseTest;
import com.hilgo.rotax.dto.CargoDTO;
import com.hilgo.rotax.dto.CargoOfferDTO;
import com.hilgo.rotax.dto.DriverDashboardResponse;
import com.hilgo.rotax.dto.DriverStatusUpdateRequest;
import com.hilgo.rotax.entity.Cargo;
import com.hilgo.rotax.entity.Driver;
import com.hilgo.rotax.entity.Location;
import com.hilgo.rotax.entity.Measure;
import com.hilgo.rotax.enums.CargoSituation;
import com.hilgo.rotax.enums.DriverStatus;
import com.hilgo.rotax.enums.Size;
import com.hilgo.rotax.exception.ResourceNotFoundException;
import com.hilgo.rotax.repository.CargoRepository;
import com.hilgo.rotax.repository.DriverRepository;
import com.hilgo.rotax.repository.LocationRepository;
import com.hilgo.rotax.repository.ReviewRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class DriverServiceTest extends BaseTest {

    @Mock
    private DriverRepository driverRepository;

    @Mock
    private LocationRepository locationRepository;

    @Mock
    private CargoRepository cargoRepository;

    @Mock
    private ReviewRepository reviewRepository;

    @Mock
    private SecurityContext securityContext;

    @Mock
    private Authentication authentication;

    @InjectMocks
    private DriverService driverService;

    private Driver testDriver;
    private Location testLocation;
    private Cargo testCargo;

    @BeforeEach
    void setUp() {
        // Setup security context mock
        when(securityContext.getAuthentication()).thenReturn(authentication);
        SecurityContextHolder.setContext(securityContext);
        when(authentication.getName()).thenReturn("testdriver");

        // Setup test driver
        testDriver = new Driver();
        testDriver.setId(1L);
        testDriver.setUsername("testdriver");
        testDriver.setFirstName("Test");
        testDriver.setLastName("Driver");
        testDriver.setDriverStatus(DriverStatus.ACTIVE);

        // Setup test location
        testLocation = new Location();
        testLocation.setId(1L);
        testLocation.setLatitude(40.7128);
        testLocation.setLongitude(-74.0060);
        testLocation.setAddress("123 Test St");
        testLocation.setCity("Test City");
        testLocation.setDistrict("Test District");
        testLocation.setPostalCode("12345");
        testDriver.setLocation(testLocation);

        // Setup test cargo
        testCargo = new Cargo();
        testCargo.setId(1L);
        testCargo.setCargoSituation(CargoSituation.ASSIGNED);
        testCargo.setDriver(testDriver);
        testCargo.setCreatedAt(LocalDateTime.now());
        testCargo.setUpdatedAt(LocalDateTime.now());
        
        // Setup test measure
        Measure measure = new Measure();
        measure.setId(1L);
        measure.setWeight(10.0);
        measure.setWidth(20.0);
        measure.setHeight(30.0);
        measure.setLength(40.0);
        measure.setSize(Size.MEDIUM);
        testCargo.setMeasure(measure);
        
        // Setup test locations for cargo
        Location selfLocation = new Location();
        selfLocation.setId(2L);
        selfLocation.setLatitude(40.7128);
        selfLocation.setLongitude(-74.0060);
        selfLocation.setAddress("456 Pickup St");
        selfLocation.setCity("Pickup City");
        
        Location targetLocation = new Location();
        targetLocation.setId(3L);
        targetLocation.setLatitude(34.0522);
        targetLocation.setLongitude(-118.2437);
        targetLocation.setAddress("789 Delivery St");
        targetLocation.setCity("Delivery City");
        
        testCargo.setSelfLocation(selfLocation);
        testCargo.setTargetLocation(targetLocation);

        // Setup repository mocks
        when(driverRepository.findByUsername("testdriver")).thenReturn(Optional.of(testDriver));
        when(cargoRepository.findByDriver(any(Driver.class))).thenReturn(List.of(testCargo));
        when(reviewRepository.getAverageRatingForDriver(anyLong())).thenReturn(4.5);
    }

    @Test
    void getCurrentDriver_ShouldReturnDriver_WhenDriverExists() {
        // Act
        Driver result = driverService.getCurrentDriver();

        // Assert
        assertNotNull(result);
        assertEquals("testdriver", result.getUsername());
        assertEquals("Test", result.getFirstName());
        assertEquals("Driver", result.getLastName());
        verify(driverRepository).findByUsername("testdriver");
    }

    @Test
    void getCurrentDriver_ShouldThrowException_WhenDriverDoesNotExist() {
        // Arrange
        when(driverRepository.findByUsername("testdriver")).thenReturn(Optional.empty());

        // Act & Assert
        assertThrows(ResourceNotFoundException.class, () -> driverService.getCurrentDriver());
        verify(driverRepository).findByUsername("testdriver");
    }

    @Test
    void updateDriverStatus_ShouldUpdateStatus() {
        // Arrange
        DriverStatusUpdateRequest request = new DriverStatusUpdateRequest();
        request.setStatus(DriverStatus.DESTINATION_BASED);
        
        com.hilgo.rotax.dto.LocationDTO locationDTO = new com.hilgo.rotax.dto.LocationDTO();
        locationDTO.setLatitude(41.8781);
        locationDTO.setLongitude(-87.6298);
        locationDTO.setAddress("321 New St");
        locationDTO.setCity("New City");
        locationDTO.setDistrict("New District");
        locationDTO.setPostalCode("54321");
        request.setLocation(locationDTO);

        // Act
        driverService.updateDriverStatus(request);

        // Assert
        verify(driverRepository).save(testDriver);
        verify(locationRepository).save(any(Location.class));
        assertEquals(DriverStatus.DESTINATION_BASED, testDriver.getDriverStatus());
    }

    @Test
    void getDriverDashboard_ShouldReturnDashboard() {
        // Act
        DriverDashboardResponse response = driverService.getDriverDashboard();

        // Assert
        assertNotNull(response);
        assertEquals(1L, response.getDriverId());
        assertEquals("Test Driver", response.getDriverName());
        assertEquals(4.5, response.getAverageRating());
        assertEquals(1, response.getActiveDeliveries());
        assertEquals(1, response.getCurrentCargos().size());
        verify(cargoRepository).findByDriver(testDriver);
        verify(reviewRepository).getAverageRatingForDriver(1L);
    }

    @Test
    void getAvailableOffers_ShouldReturnOffers_WhenDriverIsActive() {
        // Arrange
        Cargo availableCargo = new Cargo();
        availableCargo.setId(2L);
        availableCargo.setCargoSituation(CargoSituation.CREATED);
        availableCargo.setSelfLocation(testLocation);
        availableCargo.setTargetLocation(testLocation);
        availableCargo.setMeasure(testCargo.getMeasure());
        
        when(cargoRepository.findNearbyCargos(
                eq(CargoSituation.CREATED), 
                anyDouble(), 
                anyDouble(), 
                anyDouble()))
                .thenReturn(List.of(availableCargo));

        // Act
        List<CargoOfferDTO> offers = driverService.getAvailableOffers();

        // Assert
        assertNotNull(offers);
        assertEquals(1, offers.size());
        verify(cargoRepository).findNearbyCargos(
                eq(CargoSituation.CREATED), 
                anyDouble(), 
                anyDouble(), 
                anyDouble());
    }

    @Test
    void acceptOffer_ShouldAssignCargoToDriver() {
        // Arrange
        Cargo availableCargo = new Cargo();
        availableCargo.setId(2L);
        availableCargo.setCargoSituation(CargoSituation.CREATED);
        availableCargo.setSelfLocation(testLocation);
        availableCargo.setTargetLocation(testLocation);
        availableCargo.setMeasure(testCargo.getMeasure());
        
        when(cargoRepository.findById(2L)).thenReturn(Optional.of(availableCargo));
        when(cargoRepository.save(any(Cargo.class))).thenReturn(availableCargo);

        // Act
        CargoDTO result = driverService.acceptOffer(2L);

        // Assert
        assertNotNull(result);
        verify(cargoRepository).findById(2L);
        verify(cargoRepository).save(availableCargo);
        assertEquals(CargoSituation.ASSIGNED, availableCargo.getCargoSituation());
        assertEquals(testDriver, availableCargo.getDriver());
    }

    @Test
    void updateCargoStatus_ShouldUpdateStatus_WhenValidTransition() {
        // Arrange
        when(cargoRepository.findById(1L)).thenReturn(Optional.of(testCargo));
        when(cargoRepository.save(any(Cargo.class))).thenReturn(testCargo);

        // Act
        CargoDTO result = driverService.updateCargoStatus(1L, CargoSituation.PICKED_UP);

        // Assert
        assertNotNull(result);
        verify(cargoRepository).findById(1L);
        verify(cargoRepository).save(testCargo);
        assertEquals(CargoSituation.PICKED_UP, testCargo.getCargoSituation());
        assertNotNull(testCargo.getTakingTime());
    }

    @Test
    void updateCargoStatus_ShouldThrowException_WhenInvalidTransition() {
        // Arrange
        when(cargoRepository.findById(1L)).thenReturn(Optional.of(testCargo));

        // Act & Assert
        assertThrows(RuntimeException.class, () -> 
            driverService.updateCargoStatus(1L, CargoSituation.CREATED));
        
        verify(cargoRepository).findById(1L);
        verify(cargoRepository, never()).save(any(Cargo.class));
    }
}