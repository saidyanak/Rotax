package com.hilgo.rotax.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.hilgo.rotax.dto.DriverStatusUpdateRequest;
import com.hilgo.rotax.dto.LocationDTO;
import com.hilgo.rotax.dto.ProfileUpdateRequestDTO;
import com.hilgo.rotax.entity.Cargo;
import com.hilgo.rotax.entity.Distributor;
import com.hilgo.rotax.entity.Driver;
import com.hilgo.rotax.entity.Location;
import com.hilgo.rotax.enums.CarType;
import com.hilgo.rotax.enums.CargoSituation;
import com.hilgo.rotax.enums.DriverStatus;
import com.hilgo.rotax.enums.Roles;
import com.hilgo.rotax.repository.CargoRepository;
import com.hilgo.rotax.repository.DistributorRepository;
import com.hilgo.rotax.repository.DriverRepository;
import com.hilgo.rotax.repository.LocationRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class DriverControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private DriverRepository driverRepository;

    @Autowired
    private DistributorRepository distributorRepository;

    @Autowired
    private CargoRepository cargoRepository;

    @Autowired
    private LocationRepository locationRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private Driver testDriver;
    private Cargo testCargo;

    @BeforeEach
    void setUp() {
        // Test için bir sürücü oluştur
        testDriver = new Driver();
        testDriver.setUsername("testdriver");
        testDriver.setPassword(passwordEncoder.encode("password"));
        testDriver.setFirstName("Test");
        testDriver.setLastName("Driver");
        testDriver.setEmail("driver@test.com");
        testDriver.setPhoneNumber("1234567890");
        testDriver.setRole(Roles.DRIVER);
        testDriver.setEnabled(true); // Testlerde işlem yapabilmesi için aktif olmalı
        testDriver.setDriverStatus(DriverStatus.ACTIVE);
        driverRepository.save(testDriver);

        // Test için bir dağıtıcı oluştur
        Distributor testDistributor = new Distributor();
        testDistributor.setUsername("testdistributor");
        testDistributor.setPassword(passwordEncoder.encode("password"));
        testDistributor.setFirstName("Test");
        testDistributor.setLastName("Distributor");
        testDistributor.setEmail("distributor@test.com");
        testDistributor.setPhoneNumber("0987654321");
        testDistributor.setRole(Roles.DISTRIBUTOR);
        testDistributor.setEnabled(true);
        distributorRepository.save(testDistributor);

        // Test için bir kargo oluştur
        Location location = locationRepository.save(new Location());
        testCargo = new Cargo();
        testCargo.setDistributor(testDistributor);
        testCargo.setSelfLocation(location);
        testCargo.setTargetLocation(location);
        testCargo.setCargoSituation(CargoSituation.CREATED);
        cargoRepository.save(testCargo);
    }

    @Test
    @WithMockUser(username = "testdriver", roles = "DRIVER")
    void updateStatus_ShouldUpdateDriverStatusAndLocation() throws Exception {
        LocationDTO locationDTO = new LocationDTO();
        locationDTO.setLatitude(41.0);
        locationDTO.setLongitude(29.0);

        DriverStatusUpdateRequest request = new DriverStatusUpdateRequest();
        request.setStatus(DriverStatus.OFFLINE);
        request.setLocation(locationDTO);

        mockMvc.perform(put("/api/driver/status")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success", is(true)));

        Driver updatedDriver = driverRepository.findByUsername("testdriver").get();
        assertEquals(DriverStatus.OFFLINE, updatedDriver.getDriverStatus());
        assertEquals(41.0, updatedDriver.getLocation().getLatitude());
    }

    @Test
    @WithMockUser(username = "testdriver", roles = "DRIVER")
    void updateProfile_ShouldUpdateDriverProfile() throws Exception {
        ProfileUpdateRequestDTO request = new ProfileUpdateRequestDTO();
        request.setFirstName("UpdatedName");
        request.setCarType(CarType.HATCHBACK);

        mockMvc.perform(put("/api/driver/profile")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.firstName", is("UpdatedName")));

        Driver updatedDriver = driverRepository.findByUsername("testdriver").get();
        assertEquals("UpdatedName", updatedDriver.getFirstName());
        assertEquals(CarType.HATCHBACK, updatedDriver.getCarType());
    }

    @Test
    @WithMockUser(username = "testdriver", roles = "DRIVER")
    void uploadProfilePicture_ShouldUpdateProfilePicture() throws Exception {
        MockMultipartFile file = new MockMultipartFile(
                "file",
                "profile.jpg",
                MediaType.IMAGE_JPEG_VALUE,
                "test image content".getBytes()
        );

        mockMvc.perform(multipart("/api/driver/profile/picture").file(file))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.profilePictureUrl").exists());
    }

    @Test
    @WithMockUser(username = "testdriver", roles = "DRIVER")
    void getOffers_ShouldReturnAvailableOffers() throws Exception {
        // Bu testin daha detaylı olması için Python servisinin mock'lanması veya
        // findNearbyCargos'un deterministik sonuç vermesi sağlanabilir.
        mockMvc.perform(get("/api/driver/offers"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());
    }

    @Test
    @WithMockUser(username = "testdriver", roles = "DRIVER")
    void acceptOffer_ShouldChangeCargoStatusToAssigned() throws Exception {
        mockMvc.perform(post("/api/driver/offers/{cargoId}/accept", testCargo.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.cargoSituation", is("ASSIGNED")))
                .andExpect(jsonPath("$.driverId", is(testDriver.getId().intValue())));

        Cargo updatedCargo = cargoRepository.findById(testCargo.getId()).get();
        assertEquals(CargoSituation.ASSIGNED, updatedCargo.getCargoSituation());
        assertEquals(testDriver.getId(), updatedCargo.getDriver().getId());
    }

    @Test
    @WithMockUser(username = "testdriver", roles = "DRIVER")
    void markCargoAsPickedUp_ShouldChangeCargoStatus() throws Exception {
        testCargo.setDriver(testDriver);
        testCargo.setCargoSituation(CargoSituation.ASSIGNED);
        cargoRepository.save(testCargo);

        mockMvc.perform(put("/api/driver/cargos/{cargoId}/status/picked-up", testCargo.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.cargoSituation", is("PICKED_UP")));
    }

    @Test
    @WithMockUser(username = "testdistributor", roles = "DISTRIBUTOR")
    void acceptOffer_ShouldReturnForbidden_WhenUserIsNotaDriver() throws Exception {
        // DRIVER rolü olmayan bir kullanıcı bu endpoint'e erişememeli
        mockMvc.perform(post("/api/driver/offers/{cargoId}/accept", testCargo.getId()))
                .andExpect(status().isForbidden());
    }
}


