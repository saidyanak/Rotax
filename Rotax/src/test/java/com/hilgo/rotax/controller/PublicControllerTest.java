package com.hilgo.rotax.controller;

import com.hilgo.rotax.BaseIntegrationTest;
import com.hilgo.rotax.dto.DeliveryNoteRequest;
import com.hilgo.rotax.dto.MessageResponse;
import com.hilgo.rotax.dto.ReviewDTO;
import com.hilgo.rotax.dto.TrackingResponse;
import com.hilgo.rotax.enums.CargoSituation;
import com.hilgo.rotax.service.PublicService;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class PublicControllerTest extends BaseIntegrationTest {

    @MockBean
    private PublicService publicService;

    @Test
    void trackCargo_ShouldReturnTrackingInfo() throws Exception {
        // Arrange
        when(publicService.trackCargo(anyString())).thenReturn(
                TrackingResponse.builder()
                        .trackingCode("ABC123")
                        .status(CargoSituation.PICKED_UP)
                        .driverName("Test Driver")
                        .driverPhone("1234567890")
                        .build()
        );

        // Act & Assert
        mockMvc.perform(get("/api/public/track/ABC123"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.trackingCode").value("ABC123"))
                .andExpect(jsonPath("$.status").value("PICKED_UP"))
                .andExpect(jsonPath("$.driverName").value("Test Driver"))
                .andExpect(jsonPath("$.driverPhone").value("1234567890"));
    }

    @Test
    void addDeliveryNote_ShouldReturnSuccess() throws Exception {
        // Arrange
        DeliveryNoteRequest request = new DeliveryNoteRequest();
        request.setNote("Test delivery note");
        
        when(publicService.addDeliveryNote(anyString(), any(DeliveryNoteRequest.class)))
                .thenReturn(new MessageResponse("Delivery note added successfully"));

        // Act & Assert
        mockMvc.perform(post("/api/public/track/ABC123/note")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Delivery note added successfully"));
    }

    @Test
    void addReview_ShouldReturnSuccess() throws Exception {
        // Arrange
        ReviewDTO request = new ReviewDTO();
        request.setRating(5);
        request.setComment("Great service!");
        
        when(publicService.addReview(anyString(), any(ReviewDTO.class)))
                .thenReturn(new MessageResponse("Review added successfully"));

        // Act & Assert
        mockMvc.perform(post("/api/public/track/ABC123/review")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Review added successfully"));
    }

    @Test
    void trackCargo_ShouldReturnNotFound_WhenCargoDoesNotExist() throws Exception {
        // Arrange
        when(publicService.trackCargo(anyString()))
                .thenThrow(new com.hilgo.rotax.exception.ResourceNotFoundException("Cargo", "tracking code", "XYZ789"));

        // Act & Assert
        mockMvc.perform(get("/api/public/track/XYZ789"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Cargo not found with tracking code: XYZ789"));
    }

    @Test
    void addDeliveryNote_ShouldReturnBadRequest_WhenNoteIsEmpty() throws Exception {
        // Arrange
        DeliveryNoteRequest request = new DeliveryNoteRequest();
        request.setNote("");

        // Act & Assert
        mockMvc.perform(post("/api/public/track/ABC123/note")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void addReview_ShouldReturnBadRequest_WhenRatingIsInvalid() throws Exception {
        // Arrange
        ReviewDTO request = new ReviewDTO();
        request.setRating(6); // Invalid rating (should be 1-5)
        request.setComment("Great service!");

        // Act & Assert
        mockMvc.perform(post("/api/public/track/ABC123/review")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());
    }
}