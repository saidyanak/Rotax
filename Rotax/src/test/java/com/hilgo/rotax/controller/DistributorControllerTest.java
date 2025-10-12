package com.hilgo.rotax.controller;

import com.hilgo.rotax.BaseIntegrationTest;
import com.hilgo.rotax.dto.*;
import com.hilgo.rotax.enums.CargoSituation;
import com.hilgo.rotax.enums.Size;
import com.hilgo.rotax.service.DistributorService;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;

import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class DistributorControllerTest extends BaseIntegrationTest {

    @MockBean
    private DistributorService distributorService;

    @Test
    @WithMockUser(username = "testdistributor", roles = {"DISTRIBUTOR"})
    void getDashboard_ShouldReturnDashboard() throws Exception {
        // Arrange
        when(distributorService.getDistributorDashboard()).thenReturn(
                DistributorDashboardResponse.builder()
                        .distributorId(1L)
                        .distributorName("Test Distributor")
                        .totalCargos(10)
                        .activeCargos(5)
                        .deliveredCargos(5)
                        .build()
        );

        // Act & Assert
        mockMvc.perform(get("/api/distributor/dashboard"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.distributorId").value(1))
                .andExpect(jsonPath("$.distributorName").value("Test Distributor"))
                .andExpect(jsonPath("$.totalCargos").value(10))
                .andExpect(jsonPath("$.activeCargos").value(5))
                .andExpect(jsonPath("$.deliveredCargos").value(5));
    }

    @Test
    @WithMockUser(username = "testdistributor", roles = {"DISTRIBUTOR"})
    void createCargo_ShouldReturnCreatedCargo() throws Exception {
        // Arrange
        CreateCargoRequest request = createSampleCargoRequest();
        
        when(distributorService.createCargo(any(CreateCargoRequest.class))).thenReturn(
                CargoDTO.builder()
                        .id(1L)
                        .cargoSituation(CargoSituation.CREATED)
                        .distributorId(1L)
                        .distributorName("Test Distributor")
                        .phoneNumber("1234567890")
                        .description("Test cargo")
                        .build()
        );

        // Act & Assert
        mockMvc.perform(post("/api/distributor/cargos")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.cargoSituation").value("CREATED"))
                .andExpect(jsonPath("$.distributorId").value(1))
                .andExpect(jsonPath("$.distributorName").value("Test Distributor"))
                .andExpect(jsonPath("$.phoneNumber").value("1234567890"))
                .andExpect(jsonPath("$.description").value("Test cargo"));
    }

    @Test
    @WithMockUser(username = "testdistributor", roles = {"DISTRIBUTOR"})
    void getAllCargos_ShouldReturnAllCargos() throws Exception {
        // Arrange
        when(distributorService.getAllCargos()).thenReturn(
                List.of(
                        CargoDTO.builder()
                                .id(1L)
                                .cargoSituation(CargoSituation.CREATED)
                                .distributorId(1L)
                                .distributorName("Test Distributor")
                                .build(),
                        CargoDTO.builder()
                                .id(2L)
                                .cargoSituation(CargoSituation.DELIVERED)
                                .distributorId(1L)
                                .distributorName("Test Distributor")
                                .driverId(2L)
                                .driverName("Test Driver")
                                .build()
                )
        );

        // Act & Assert
        mockMvc.perform(get("/api/distributor/cargos"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").value(1))
                .andExpect(jsonPath("$[0].cargoSituation").value("CREATED"))
                .andExpect(jsonPath("$[1].id").value(2))
                .andExpect(jsonPath("$[1].cargoSituation").value("DELIVERED"))
                .andExpect(jsonPath("$[1].driverName").value("Test Driver"));
    }

    @Test
    @WithMockUser(username = "testdistributor", roles = {"DISTRIBUTOR"})
    void getCargoById_ShouldReturnCargo() throws Exception {
        // Arrange
        when(distributorService.getCargoById(anyLong())).thenReturn(
                CargoDTO.builder()
                        .id(1L)
                        .cargoSituation(CargoSituation.CREATED)
                        .distributorId(1L)
                        .distributorName("Test Distributor")
                        .phoneNumber("1234567890")
                        .description("Test cargo")
                        .build()
        );

        // Act & Assert
        mockMvc.perform(get("/api/distributor/cargos/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.cargoSituation").value("CREATED"))
                .andExpect(jsonPath("$.distributorId").value(1))
                .andExpect(jsonPath("$.distributorName").value("Test Distributor"));
    }

    @Test
    @WithMockUser(username = "testdistributor", roles = {"DISTRIBUTOR"})
    void cancelCargo_ShouldReturnCancelledCargo() throws Exception {
        // Arrange
        when(distributorService.cancelCargo(anyLong())).thenReturn(
                CargoDTO.builder()
                        .id(1L)
                        .cargoSituation(CargoSituation.CANCELLED)
                        .distributorId(1L)
                        .distributorName("Test Distributor")
                        .build()
        );

        // Act & Assert
        mockMvc.perform(put("/api/distributor/cargos/1/cancel"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.cargoSituation").value("CANCELLED"))
                .andExpect(jsonPath("$.distributorId").value(1))
                .andExpect(jsonPath("$.distributorName").value("Test Distributor"));
    }

    @Test
    void getDashboard_ShouldReturnUnauthorized_WhenNotAuthenticated() throws Exception {
        // Act & Assert
        mockMvc.perform(get("/api/distributor/dashboard"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @WithMockUser(username = "testuser", roles = {"DRIVER"})
    void getDashboard_ShouldReturnForbidden_WhenWrongRole() throws Exception {
        // Act & Assert
        mockMvc.perform(get("/api/distributor/dashboard"))
                .andExpect(status().isForbidden());
    }

    private CreateCargoRequest createSampleCargoRequest() {
        LocationDTO selfLocation = new LocationDTO();
        selfLocation.setLatitude(40.7128);
        selfLocation.setLongitude(-74.0060);
        selfLocation.setAddress("123 Pickup St");
        selfLocation.setCity("Pickup City");
        
        LocationDTO targetLocation = new LocationDTO();
        targetLocation.setLatitude(34.0522);
        targetLocation.setLongitude(-118.2437);
        targetLocation.setAddress("456 Delivery St");
        targetLocation.setCity("Delivery City");
        
        MeasureDTO measure = new MeasureDTO();
        measure.setWeight(10.0);
        measure.setWidth(20.0);
        measure.setHeight(30.0);
        measure.setLength(40.0);
        measure.setSize(Size.MEDIUM);
        
        CreateCargoRequest request = new CreateCargoRequest();
        request.setSelfLocation(selfLocation);
        request.setTargetLocation(targetLocation);
        request.setMeasure(measure);
        request.setPhoneNumber("1234567890");
        request.setDescription("Test cargo");
        
        return request;
    }
}