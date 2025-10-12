package com.hilgo.rotax.service;

import com.hilgo.rotax.BaseTest;
import com.hilgo.rotax.dto.DeliveryNoteRequest;
import com.hilgo.rotax.dto.MessageResponse;
import com.hilgo.rotax.dto.ReviewDTO;
import com.hilgo.rotax.dto.TrackingResponse;
import com.hilgo.rotax.entity.Cargo;
import com.hilgo.rotax.entity.Driver;
import com.hilgo.rotax.entity.Location;
import com.hilgo.rotax.enums.CargoSituation;
import com.hilgo.rotax.enums.ReviewerType;
import com.hilgo.rotax.exception.ResourceNotFoundException;
import com.hilgo.rotax.repository.CargoRepository;
import com.hilgo.rotax.repository.ReviewRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class PublicServiceTest extends BaseTest {

    @Mock
    private CargoRepository cargoRepository;

    @Mock
    private ReviewRepository reviewRepository;

    @InjectMocks
    private PublicService publicService;

    private Cargo testCargo;
    private Driver testDriver;
    private Location testLocation;

    @BeforeEach
    void setUp() {
        // Setup test driver
        testDriver = new Driver();
        testDriver.setId(1L);
        testDriver.setFirstName("Test");
        testDriver.setLastName("Driver");
        testDriver.setPhoneNumber("1234567890");

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
        testCargo.setCargoSituation(CargoSituation.PICKED_UP);
        testCargo.setDriver(testDriver);
        testCargo.setSelfLocation(testLocation);
        testCargo.setTargetLocation(testLocation);
        testCargo.setVerificationCode("ABC123");
        testCargo.setDescription("Test cargo description");

        // Setup repository mocks
        when(cargoRepository.findByVerificationCode("ABC123")).thenReturn(Optional.of(testCargo));
    }

    @Test
    void trackCargo_ShouldReturnTrackingInfo_WhenCargoExists() {
        // Act
        TrackingResponse response = publicService.trackCargo("ABC123");

        // Assert
        assertNotNull(response);
        assertEquals("ABC123", response.getTrackingCode());
        assertEquals(CargoSituation.PICKED_UP, response.getStatus());
        assertEquals("Test Driver", response.getDriverName());
        assertEquals("1234567890", response.getDriverPhone());
        assertNotNull(response.getCurrentLocation());
        assertNotNull(response.getDestinationLocation());
        verify(cargoRepository).findByVerificationCode("ABC123");
    }

    @Test
    void trackCargo_ShouldThrowException_WhenCargoDoesNotExist() {
        // Arrange
        when(cargoRepository.findByVerificationCode("XYZ789")).thenReturn(Optional.empty());

        // Act & Assert
        assertThrows(ResourceNotFoundException.class, () -> publicService.trackCargo("XYZ789"));
        verify(cargoRepository).findByVerificationCode("XYZ789");
    }

    @Test
    void addDeliveryNote_ShouldAddNote_WhenCargoExists() {
        // Arrange
        DeliveryNoteRequest request = new DeliveryNoteRequest();
        request.setNote("New delivery note");

        // Act
        MessageResponse response = publicService.addDeliveryNote("ABC123", request);

        // Assert
        assertNotNull(response);
        assertEquals("Delivery note added successfully", response.getMessage());
        assertEquals("New delivery note", testCargo.getDescription());
        verify(cargoRepository).findByVerificationCode("ABC123");
        verify(cargoRepository).save(testCargo);
    }

    @Test
    void addDeliveryNote_ShouldThrowException_WhenCargoDoesNotExist() {
        // Arrange
        when(cargoRepository.findByVerificationCode("XYZ789")).thenReturn(Optional.empty());
        DeliveryNoteRequest request = new DeliveryNoteRequest();
        request.setNote("New delivery note");

        // Act & Assert
        assertThrows(ResourceNotFoundException.class, () -> publicService.addDeliveryNote("XYZ789", request));
        verify(cargoRepository).findByVerificationCode("XYZ789");
        verify(cargoRepository, never()).save(any(Cargo.class));
    }

    @Test
    void addReview_ShouldAddReview_WhenCargoIsDelivered() {
        // Arrange
        testCargo.setCargoSituation(CargoSituation.DELIVERED);
        
        ReviewDTO reviewDTO = new ReviewDTO();
        reviewDTO.setRating(5);
        reviewDTO.setComment("Great service!");

        // Act
        MessageResponse response = publicService.addReview("ABC123", reviewDTO);

        // Assert
        assertNotNull(response);
        assertEquals("Review added successfully", response.getMessage());
        verify(cargoRepository).findByVerificationCode("ABC123");
        verify(reviewRepository).save(any());
    }

    @Test
    void addReview_ShouldThrowException_WhenCargoIsNotDelivered() {
        // Arrange
        testCargo.setCargoSituation(CargoSituation.PICKED_UP);
        
        ReviewDTO reviewDTO = new ReviewDTO();
        reviewDTO.setRating(5);
        reviewDTO.setComment("Great service!");

        // Act & Assert
        assertThrows(RuntimeException.class, () -> publicService.addReview("ABC123", reviewDTO));
        verify(cargoRepository).findByVerificationCode("ABC123");
        verify(reviewRepository, never()).save(any());
    }

    @Test
    void addReview_ShouldThrowException_WhenNoDriverAssigned() {
        // Arrange
        testCargo.setCargoSituation(CargoSituation.DELIVERED);
        testCargo.setDriver(null);
        
        ReviewDTO reviewDTO = new ReviewDTO();
        reviewDTO.setRating(5);
        reviewDTO.setComment("Great service!");

        // Act & Assert
        assertThrows(RuntimeException.class, () -> publicService.addReview("ABC123", reviewDTO));
        verify(cargoRepository).findByVerificationCode("ABC123");
        verify(reviewRepository, never()).save(any());
    }
}