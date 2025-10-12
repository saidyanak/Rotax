package com.hilgo.rotax.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.hilgo.rotax.dto.*;
import com.hilgo.rotax.entity.Address;
import com.hilgo.rotax.entity.Cargo;
import com.hilgo.rotax.entity.Distributor;
import com.hilgo.rotax.entity.Location;
import com.hilgo.rotax.enums.CargoSituation;
import com.hilgo.rotax.enums.Roles;
import com.hilgo.rotax.enums.Size;
import com.hilgo.rotax.repository.AddressRepository;
import com.hilgo.rotax.repository.CargoRepository;
import com.hilgo.rotax.repository.DistributorRepository;
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
class DistributorControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private DistributorRepository distributorRepository;

    @Autowired
    private CargoRepository cargoRepository;

    @Autowired
    private LocationRepository locationRepository;

    @Autowired
    private AddressRepository addressRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private Distributor testDistributor;
    private Cargo testCargo;

    @BeforeEach
    void setUp() {
        Address address = addressRepository.save(new Address());
        testDistributor = new Distributor();
        testDistributor.setUsername("testdistributor");
        testDistributor.setPassword(passwordEncoder.encode("password"));
        testDistributor.setFirstName("Test");
        testDistributor.setLastName("Distributor");
        testDistributor.setEmail("distributor@test.com");
        testDistributor.setPhoneNumber("0987654321");
        testDistributor.setRole(Roles.DISTRIBUTOR);
        testDistributor.setEnabled(true);
        testDistributor.setAddress(address);
        distributorRepository.save(testDistributor);

        Location location = locationRepository.save(new Location());
        testCargo = new Cargo();
        testCargo.setDistributor(testDistributor);
        testCargo.setSelfLocation(location);
        testCargo.setTargetLocation(location);
        testCargo.setCargoSituation(CargoSituation.CREATED);
        cargoRepository.save(testCargo);
    }

    @Test
    @WithMockUser(username = "testdistributor", roles = "DISTRIBUTOR")
    void getDashboard_ShouldReturnDashboard() throws Exception {
        mockMvc.perform(get("/api/distributor/dashboard"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.distributorId", is(testDistributor.getId().intValue())))
                .andExpect(jsonPath("$.totalCargos", is(1)))
                .andExpect(jsonPath("$.activeCargos", is(1)));
    }

    @Test
    @WithMockUser(username = "testdistributor", roles = "DISTRIBUTOR")
    void updateProfile_ShouldUpdateDistributorProfile() throws Exception {
        ProfileUpdateRequestDTO request = new ProfileUpdateRequestDTO();
        request.setFirstName("UpdatedDistributor");
        request.setAddress(AddressDTO.builder().city("Istanbul").build());

        mockMvc.perform(put("/api/distributor/profile")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.firstName", is("UpdatedDistributor")));

        Distributor updatedDistributor = distributorRepository.findByUsername("testdistributor").get();
        assertEquals("UpdatedDistributor", updatedDistributor.getFirstName());
        assertEquals("Istanbul", updatedDistributor.getAddress().getCity());
    }

    @Test
    @WithMockUser(username = "testdistributor", roles = "DISTRIBUTOR")
    void uploadProfilePicture_ShouldUpdateProfilePicture() throws Exception {
        MockMultipartFile file = new MockMultipartFile(
                "file",
                "distributor_profile.jpg",
                MediaType.IMAGE_JPEG_VALUE,
                "test image content".getBytes()
        );

        mockMvc.perform(multipart("/api/distributor/profile/picture").file(file))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.profilePictureUrl").exists());
    }

    @Test
    @WithMockUser(username = "testdistributor", roles = "DISTRIBUTOR")
    void createCargo_ShouldReturnCreatedCargo() throws Exception {
        CreateCargoRequest request = createSampleCargoRequest();

        mockMvc.perform(post("/api/distributor/cargos")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").exists())
                .andExpect(jsonPath("$.cargoSituation", is("CREATED")))
                .andExpect(jsonPath("$.description", is("Test cargo")));
    }

    @Test
    @WithMockUser(username = "testdistributor", roles = "DISTRIBUTOR")
    void getAllCargos_ShouldReturnAllCargos() throws Exception {
        mockMvc.perform(get("/api/distributor/cargos"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].id", is(testCargo.getId().intValue())));
    }

    @Test
    @WithMockUser(username = "testdistributor", roles = "DISTRIBUTOR")
    void getCargoById_ShouldReturnCargo() throws Exception {
        mockMvc.perform(get("/api/distributor/cargos/{cargoId}", testCargo.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id", is(testCargo.getId().intValue())))
                .andExpect(jsonPath("$.distributorId", is(testDistributor.getId().intValue())));
    }

    @Test
    @WithMockUser(username = "testdistributor", roles = "DISTRIBUTOR")
    void cancelCargo_ShouldReturnCancelledCargo() throws Exception {
        mockMvc.perform(put("/api/distributor/cargos/{cargoId}/cancel", testCargo.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.cargoSituation", is("CANCELLED")));

        Cargo cancelledCargo = cargoRepository.findById(testCargo.getId()).get();
        assertEquals(CargoSituation.CANCELLED, cancelledCargo.getCargoSituation());
    }

    @Test
    @WithMockUser(username = "testdriver", roles = "DRIVER")
    void getDashboard_ShouldReturnForbidden_WhenWrongRole() throws Exception {
        mockMvc.perform(get("/api/distributor/dashboard"))
                .andExpect(status().isForbidden());
    }

    private CreateCargoRequest createSampleCargoRequest() {
        LocationDTO selfLocation = new LocationDTO();
        selfLocation.setLatitude(40.7128);
        selfLocation.setLongitude(-74.0060);
        selfLocation.setAddress("123 Pickup St");
        selfLocation.setCity("Pickup City");
        selfLocation.setDistrict("Test District");
        selfLocation.setPostalCode("12345");

        LocationDTO targetLocation = new LocationDTO();
        targetLocation.setLatitude(34.0522);
        targetLocation.setLongitude(-118.2437);
        targetLocation.setAddress("456 Delivery St");
        targetLocation.setCity("Delivery City");
        targetLocation.setDistrict("Target District");
        targetLocation.setPostalCode("67890");

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