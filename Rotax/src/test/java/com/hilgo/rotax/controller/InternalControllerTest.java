package com.hilgo.rotax.controller;

import com.hilgo.rotax.BaseIntegrationTest;
import com.hilgo.rotax.entity.Driver;
import com.hilgo.rotax.entity.Location;
import com.hilgo.rotax.enums.CarType;
import com.hilgo.rotax.enums.DriverStatus;
import com.hilgo.rotax.enums.Roles;
import com.hilgo.rotax.repository.DriverRepository;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

import java.util.List;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.springframework.security.test.context.support.WithMockUser; // <-- BU IMPORT'U EKLE
import org.springframework.transaction.annotation.Transactional;

@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@WithMockUser(roles = "ADMIN") // <-- BU SATIRI SINIFIN BAŞINA EKLE
class InternalControllerTest extends BaseIntegrationTest {

    @MockitoBean
    private DriverRepository driverRepository;

    @Test
    void getAvailableDrivers_ShouldReturnActiveDrivers() throws Exception {
        // Arrange
        Location location1 = new Location();
        location1.setId(1L);
        location1.setLatitude(40.7128);
        location1.setLongitude(-74.0060);
        location1.setAddress("123 Test St");
        location1.setCity("New York");
        location1.setDistrict("Manhattan");
        location1.setPostalCode("10001");

        Location location2 = new Location();
        location2.setId(2L);
        location2.setLatitude(34.0522);
        location2.setLongitude(-118.2437);
        location2.setAddress("456 Test Ave");
        location2.setCity("Los Angeles");
        location2.setDistrict("Downtown");
        location2.setPostalCode("90001");

        Driver driver1 = new Driver();
        driver1.setId(1L);
        driver1.setUsername("driver1");
        driver1.setFirstName("John");
        driver1.setLastName("Doe");
        driver1.setEmail("john@example.com");
        driver1.setTc("12345678901");
        driver1.setDriverStatus(DriverStatus.ACTIVE);
        driver1.setRole(Roles.DRIVER); // <-- BU SATIRI EKLE
        driver1.setCarType(CarType.HATCHBACK);
        driver1.setLocation(location1);

        Driver driver2 = new Driver();
        driver2.setId(2L);
        driver2.setUsername("driver2");
        driver2.setFirstName("Jane");
        driver2.setLastName("Smith");
        driver2.setEmail("jane@example.com");
        driver2.setTc("12345678902");
        driver2.setRole(Roles.DRIVER); // <-- BU SATIRI EKLE
        driver2.setDriverStatus(DriverStatus.ACTIVE);
        driver2.setCarType(CarType.MINIVAN);
        driver2.setLocation(location2);

        when(driverRepository.findAllByDriverStatus(DriverStatus.ACTIVE))
                .thenReturn(List.of(driver1, driver2));

        // Act & Assert
        mockMvc.perform(get("/api/internal/drivers/available")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").value(1))
                .andExpect(jsonPath("$[0].username").value("driver1"))
                .andExpect(jsonPath("$[0].firstName").value("John"))
                .andExpect(jsonPath("$[0].lastName").value("Doe"))
                .andExpect(jsonPath("$[0].driverStatus").value("ACTIVE"))
                .andExpect(jsonPath("$[0].carType").value("HATCHBACK"))
                .andExpect(jsonPath("$[1].id").value(2))
                .andExpect(jsonPath("$[1].username").value("driver2"))
                .andExpect(jsonPath("$[1].firstName").value("Jane"))
                .andExpect(jsonPath("$[1].lastName").value("Smith"))
                .andExpect(jsonPath("$[1].driverStatus").value("ACTIVE"))
                .andExpect(jsonPath("$[1].carType").value("MINIVAN"));
    }

    @Test
    void getAvailableDrivers_ShouldReturnEmptyList_WhenNoActiveDrivers() throws Exception {
        // Arrange
        when(driverRepository.findAllByDriverStatus(DriverStatus.ACTIVE))
                .thenReturn(List.of());

        // Act & Assert
        mockMvc.perform(get("/api/internal/drivers/available")
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$").isEmpty());
    }
}