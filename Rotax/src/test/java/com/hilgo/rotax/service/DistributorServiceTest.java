package com.hilgo.rotax.service;

import com.hilgo.rotax.BaseTest;
import com.hilgo.rotax.dto.*;
import com.hilgo.rotax.entity.Cargo;
import com.hilgo.rotax.entity.Distributor;
import com.hilgo.rotax.entity.Location;
import com.hilgo.rotax.entity.Measure;
import com.hilgo.rotax.enums.CargoSituation;
import com.hilgo.rotax.enums.Size;
import com.hilgo.rotax.exception.ResourceNotFoundException;
import com.hilgo.rotax.repository.CargoRepository;
import com.hilgo.rotax.repository.DistributorRepository;
import com.hilgo.rotax.repository.LocationRepository;
import com.hilgo.rotax.repository.MeasureRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class DistributorServiceTest extends BaseTest {

    @Mock
    private DistributorRepository distributorRepository;

    @Mock
    private CargoRepository cargoRepository;

    @Mock
    private LocationRepository locationRepository;

    @Mock
    private MeasureRepository measureRepository;

    @Mock
    private SecurityContext securityContext;

    @Mock
    private Authentication authentication;

    @InjectMocks
    private DistributorService distributorService;

    private Distributor testDistributor;
    private Cargo testCargo;
    private Location testLocation;
    private Measure testMeasure;

    @BeforeEach
    void setUp() {
        // Setup security context mock
        when(securityContext.getAuthentication()).thenReturn(authentication);
        SecurityContextHolder.setContext(securityContext);
        when(authentication.getName()).thenReturn("testdistributor");

        // Setup test distributor
        testDistributor = new Distributor();
        testDistributor.setId(1L);
        testDistributor.setUsername("testdistributor");
        testDistributor.setFirstName("Test");
        testDistributor.setLastName("Distributor");

        // Setup test location
        testLocation = new Location();
        testLocation.setId(1L);
        testLocation.setLatitude(40.7128);
        testLocation.setLongitude(-74.0060);
        testLocation.setAddress("123 Test St");
        testLocation.setCity("Test City");
        testLocation.setDistrict("Test District");
        testLocation.setPostalCode("12345");

        // Setup test measure
        testMeasure = new Measure();
        testMeasure.setId(1L);
        testMeasure.setWeight(10.0);
        testMeasure.setWidth(20.0);
        testMeasure.setHeight(30.0);
        testMeasure.setLength(40.0);
        testMeasure.setSize(Size.MEDIUM);

        // Setup test cargo
        testCargo = new Cargo();
        testCargo.setId(1L);
        testCargo.setDistributor(testDistributor);
        testCargo.setCargoSituation(CargoSituation.CREATED);
        testCargo.setSelfLocation(testLocation);
        testCargo.setTargetLocation(testLocation);
        testCargo.setMeasure(testMeasure);
        testCargo.setPhoneNumber("1234567890");
        testCargo.setDescription("Test cargo");
        testCargo.setCreatedAt(LocalDateTime.now());
        testCargo.setUpdatedAt(LocalDateTime.now());
        testCargo.setVerificationCode("ABC123");

        // Setup repository mocks
        when(distributorRepository.findByUsername("testdistributor")).thenReturn(Optional.of(testDistributor));
        when(cargoRepository.findByDistributor(any(Distributor.class))).thenReturn(List.of(testCargo));
        when(cargoRepository.save(any(Cargo.class))).thenReturn(testCargo);
        when(locationRepository.save(any(Location.class))).thenReturn(testLocation);
        when(measureRepository.save(any(Measure.class))).thenReturn(testMeasure);
    }

    @Test
    void getCurrentDistributor_ShouldReturnDistributor_WhenDistributorExists() {
        // Act
        Distributor result = distributorService.getCurrentDistributor();

        // Assert
        assertNotNull(result);
        assertEquals("testdistributor", result.getUsername());
        assertEquals("Test", result.getFirstName());
        assertEquals("Distributor", result.getLastName());
        verify(distributorRepository).findByUsername("testdistributor");
    }

    @Test
    void getCurrentDistributor_ShouldThrowException_WhenDistributorDoesNotExist() {
        // Arrange
        when(distributorRepository.findByUsername("testdistributor")).thenReturn(Optional.empty());

        // Act & Assert
        assertThrows(ResourceNotFoundException.class, () -> distributorService.getCurrentDistributor());
        verify(distributorRepository).findByUsername("testdistributor");
    }

    @Test
    void getDistributorDashboard_ShouldReturnDashboard() {
        // Act
        DistributorDashboardResponse response = distributorService.getDistributorDashboard();

        // Assert
        assertNotNull(response);
        assertEquals(1L, response.getDistributorId());
        assertEquals("Test Distributor", response.getDistributorName());
        assertEquals(1, response.getTotalCargos());
        assertEquals(1, response.getActiveCargos());
        assertEquals(0, response.getDeliveredCargos());
        assertEquals(1, response.getCurrentCargos().size());
        assertEquals(0, response.getRecentCargos().size());
        verify(cargoRepository).findByDistributor(testDistributor);
    }

    @Test
    void createCargo_ShouldCreateAndReturnCargo() {
        // Arrange
        CreateCargoRequest request = new CreateCargoRequest();
        
        LocationDTO selfLocationDTO = new LocationDTO();
        selfLocationDTO.setLatitude(40.7128);
        selfLocationDTO.setLongitude(-74.0060);
        selfLocationDTO.setAddress("123 Test St");
        selfLocationDTO.setCity("Test City");
        selfLocationDTO.setDistrict("Test District");
        selfLocationDTO.setPostalCode("12345");
        request.setSelfLocation(selfLocationDTO);
        
        LocationDTO targetLocationDTO = new LocationDTO();
        targetLocationDTO.setLatitude(34.0522);
        targetLocationDTO.setLongitude(-118.2437);
        targetLocationDTO.setAddress("456 Target St");
        targetLocationDTO.setCity("Target City");
        targetLocationDTO.setDistrict("Target District");
        targetLocationDTO.setPostalCode("67890");
        request.setTargetLocation(targetLocationDTO);
        
        MeasureDTO measureDTO = new MeasureDTO();
        measureDTO.setWeight(10.0);
        measureDTO.setWidth(20.0);
        measureDTO.setHeight(30.0);
        measureDTO.setLength(40.0);
        measureDTO.setSize(Size.MEDIUM);
        request.setMeasure(measureDTO);
        
        request.setPhoneNumber("1234567890");
        request.setDescription("Test cargo description");

        // Act
        CargoDTO result = distributorService.createCargo(request);

        // Assert
        assertNotNull(result);
        verify(locationRepository, times(2)).save(any(Location.class));
        verify(measureRepository).save(any(Measure.class));
        verify(cargoRepository).save(any(Cargo.class));
    }

    @Test
    void getAllCargos_ShouldReturnAllCargos() {
        // Act
        List<CargoDTO> result = distributorService.getAllCargos();

        // Assert
        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals(1L, result.get(0).getId());
        assertEquals(CargoSituation.CREATED, result.get(0).getCargoSituation());
        verify(cargoRepository).findByDistributor(testDistributor);
    }

    @Test
    void getCargoById_ShouldReturnCargo_WhenCargoExists() {
        // Arrange
        when(cargoRepository.findById(1L)).thenReturn(Optional.of(testCargo));

        // Act
        CargoDTO result = distributorService.getCargoById(1L);

        // Assert
        assertNotNull(result);
        assertEquals(1L, result.getId());
        assertEquals(CargoSituation.CREATED, result.getCargoSituation());
        verify(cargoRepository).findById(1L);
    }

    @Test
    void getCargoById_ShouldThrowException_WhenCargoDoesNotExist() {
        // Arrange
        when(cargoRepository.findById(1L)).thenReturn(Optional.empty());

        // Act & Assert
        assertThrows(ResourceNotFoundException.class, () -> distributorService.getCargoById(1L));
        verify(cargoRepository).findById(1L);
    }

    @Test
    void cancelCargo_ShouldCancelCargo_WhenCargoCanBeCancelled() {
        // Arrange
        when(cargoRepository.findById(1L)).thenReturn(Optional.of(testCargo));

        // Act
        CargoDTO result = distributorService.cancelCargo(1L);

        // Assert
        assertNotNull(result);
        verify(cargoRepository).findById(1L);
        verify(cargoRepository).save(testCargo);
        assertEquals(CargoSituation.CANCELLED, testCargo.getCargoSituation());
    }

    @Test
    void cancelCargo_ShouldThrowException_WhenCargoCannotBeCancelled() {
        // Arrange
        testCargo.setCargoSituation(CargoSituation.DELIVERED);
        when(cargoRepository.findById(1L)).thenReturn(Optional.of(testCargo));

        // Act & Assert
        assertThrows(RuntimeException.class, () -> distributorService.cancelCargo(1L));
        verify(cargoRepository).findById(1L);
        verify(cargoRepository, never()).save(any(Cargo.class));
    }
}