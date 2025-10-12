package com.hilgo.rotax.controller;

import com.hilgo.rotax.BaseIntegrationTest;
import com.hilgo.rotax.dto.CargoDTO;
import com.hilgo.rotax.enums.CargoSituation;
import com.hilgo.rotax.service.DriverService;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;

import java.util.List;

import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class InternalControllerTest extends BaseIntegrationTest {

    @MockBean
    private DriverService driverService;

    @Test
    void getDriverCargos_ShouldReturnCargos_WhenApiKeyIsValid() throws Exception {
        // Arrange
        when(driverService.getDriverCargos(anyLong())).thenReturn(
                List.of(
                        CargoDTO.builder()
                                .id(1L)
                                .cargoSituation(CargoSituation.ASSIGNED)
                                .driverId(1L)
                                .driverName("Test Driver")
                                .distributorId(2L)
                                .distributorName("Test Distributor")
                                .build()
                )
        );

        // Act & Assert
        mockMvc.perform(get("/api/internal/drivers/1/cargos")
                .header("X-API-KEY", "test-api-key")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").value(1))
                .andExpect(jsonPath("$[0].cargoSituation").value("ASSIGNED"))
                .andExpect(jsonPath("$[0].driverId").value(1))
                .andExpect(jsonPath("$[0].driverName").value("Test Driver"));
    }

    @Test
    void getDriverCargos_ShouldReturnUnauthorized_WhenApiKeyIsInvalid() throws Exception {
        // Act & Assert
        mockMvc.perform(get("/api/internal/drivers/1/cargos")
                .header("X-API-KEY", "invalid-api-key")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void getDriverCargos_ShouldReturnUnauthorized_WhenApiKeyIsMissing() throws Exception {
        // Act & Assert
        mockMvc.perform(get("/api/internal/drivers/1/cargos")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isUnauthorized());
    }
}