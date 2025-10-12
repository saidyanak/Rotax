package com.hilgo.rotax.controller;

import com.hilgo.rotax.BaseIntegrationTest;
import com.hilgo.rotax.dto.DriverStatusUpdateRequest;
import com.hilgo.rotax.dto.LocationDTO;
import com.hilgo.rotax.enums.DriverStatus;
import com.hilgo.rotax.service.DriverService;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class DriverControllerTest extends BaseIntegrationTest {

    @MockitoBean
    private DriverService driverService;

    @Test
    @WithMockUser(username = "testdriver", roles = {"DRIVER"})
    void updateStatus_ShouldReturnSuccess() throws Exception {
        // Arrange
        DriverStatusUpdateRequest request = new DriverStatusUpdateRequest();
        request.setStatus(DriverStatus.ACTIVE);
        
        LocationDTO locationDTO = new LocationDTO();
        locationDTO.setLatitude(40.7128);
        locationDTO.setLongitude(-74.0060);
        locationDTO.setAddress("123 Test St");
        locationDTO.setCity("Test City");
        request.setLocation(locationDTO);
        
        doNothing().when(driverService).updateDriverStatus(any(DriverStatusUpdateRequest.class));

        // Act & Assert
        mockMvc.perform(put("/api/driver/status")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Driver status updated successfully"));
    }

    @Test
    @WithMockUser(username = "testdriver", roles = {"DRIVER"})
    void getDashboard_ShouldReturnDashboard() throws Exception {
        // Arrange
        when(driverService.getDriverDashboard()).thenReturn(
                com.hilgo.rotax.dto.DriverDashboardResponse.builder()
                        .driverId(1L)
                        .driverName("Test Driver")
                        .averageRating(4.5)
                        .totalDeliveries(10)
                        .activeDeliveries(2)
                        .build()
        );

        // Act & Assert
        mockMvc.perform(get("/api/driver/dashboard"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.driverId").value(1))
                .andExpect(jsonPath("$.driverName").value("Test Driver"))
                .andExpect(jsonPath("$.averageRating").value(4.5))
                .andExpect(jsonPath("$.totalDeliveries").value(10))
                .andExpect(jsonPath("$.activeDeliveries").value(2));
    }

    @Test
    @WithMockUser(username = "testdriver", roles = {"DRIVER"})
    void getOffers_ShouldReturnOffers() throws Exception {
        // Arrange
        when(driverService.getAvailableOffers()).thenReturn(
                java.util.List.of(
                        com.hilgo.rotax.dto.CargoOfferDTO.builder()
                                .cargoId(1L)
                                .distanceToPickup(5.0)
                                .totalDistance(20.0)
                                .estimatedEarning(50.0)
                                .distributorName("Test Distributor")
                                .build()
                )
        );

        // Act & Assert
        mockMvc.perform(get("/api/driver/offers"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].cargoId").value(1))
                .andExpect(jsonPath("$[0].distanceToPickup").value(5.0))
                .andExpect(jsonPath("$[0].totalDistance").value(20.0))
                .andExpect(jsonPath("$[0].estimatedEarning").value(50.0))
                .andExpect(jsonPath("$[0].distributorName").value("Test Distributor"));
    }

    @Test
    @WithMockUser(username = "testdriver", roles = {"DRIVER"})
    void acceptOffer_ShouldReturnAcceptedCargo() throws Exception {
        // Arrange
        when(driverService.acceptOffer(anyLong())).thenReturn(
                com.hilgo.rotax.dto.CargoDTO.builder()
                        .id(1L)
                        .cargoSituation(com.hilgo.rotax.enums.CargoSituation.ASSIGNED)
                        .driverId(1L)
                        .driverName("Test Driver")
                        .distributorId(2L)
                        .distributorName("Test Distributor")
                        .build()
        );

        // Act & Assert
        mockMvc.perform(post("/api/driver/offers/1/accept"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.cargoSituation").value("ASSIGNED"))
                .andExpect(jsonPath("$.driverId").value(1))
                .andExpect(jsonPath("$.driverName").value("Test Driver"))
                .andExpect(jsonPath("$.distributorId").value(2))
                .andExpect(jsonPath("$.distributorName").value("Test Distributor"));
    }

    @Test
    @WithMockUser(username = "testdriver", roles = {"DRIVER"})
    void markCargoAsPickedUp_ShouldReturnUpdatedCargo() throws Exception {
        // Arrange
        when(driverService.updateCargoStatus(anyLong(), any())).thenReturn(
                com.hilgo.rotax.dto.CargoDTO.builder()
                        .id(1L)
                        .cargoSituation(com.hilgo.rotax.enums.CargoSituation.PICKED_UP)
                        .driverId(1L)
                        .driverName("Test Driver")
                        .build()
        );

        // Act & Assert
        mockMvc.perform(put("/api/driver/cargos/1/status/picked-up"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.cargoSituation").value("PICKED_UP"))
                .andExpect(jsonPath("$.driverId").value(1))
                .andExpect(jsonPath("$.driverName").value("Test Driver"));
    }

    @Test
    @WithMockUser(username = "testdriver", roles = {"DRIVER"})
    void markCargoAsDelivered_ShouldReturnUpdatedCargo() throws Exception {
        // Arrange
        when(driverService.updateCargoStatus(anyLong(), any())).thenReturn(
                com.hilgo.rotax.dto.CargoDTO.builder()
                        .id(1L)
                        .cargoSituation(com.hilgo.rotax.enums.CargoSituation.DELIVERED)
                        .driverId(1L)
                        .driverName("Test Driver")
                        .build()
        );

        // Act & Assert
        mockMvc.perform(put("/api/driver/cargos/1/status/delivered"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.cargoSituation").value("DELIVERED"))
                .andExpect(jsonPath("$.driverId").value(1))
                .andExpect(jsonPath("$.driverName").value("Test Driver"));
    }

    @Test
    void updateStatus_ShouldReturnUnauthorized_WhenNotAuthenticated() throws Exception {
        // Arrange
        DriverStatusUpdateRequest request = new DriverStatusUpdateRequest();
        request.setStatus(DriverStatus.ACTIVE);
        
        LocationDTO locationDTO = new LocationDTO();
        locationDTO.setLatitude(40.7128);
        locationDTO.setLongitude(-74.0060);
        request.setLocation(locationDTO);

        // Act & Assert
        mockMvc.perform(put("/api/driver/status")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @WithMockUser(username = "testuser", roles = {"DISTRIBUTOR"})
    void updateStatus_ShouldReturnForbidden_WhenWrongRole() throws Exception {
        // Arrange
        DriverStatusUpdateRequest request = new DriverStatusUpdateRequest();
        request.setStatus(DriverStatus.ACTIVE);
        
        LocationDTO locationDTO = new LocationDTO();
        locationDTO.setLatitude(40.7128);
        locationDTO.setLongitude(-74.0060);
        request.setLocation(locationDTO);

        // Act & Assert
        mockMvc.perform(put("/api/driver/status")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden());
    }
}