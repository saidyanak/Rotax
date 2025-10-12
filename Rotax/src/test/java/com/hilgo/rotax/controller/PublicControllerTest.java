package com.hilgo.rotax.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.hilgo.rotax.dto.DeliveryNoteRequest;
import com.hilgo.rotax.dto.ReviewDTO;
import com.hilgo.rotax.entity.Cargo;
import com.hilgo.rotax.entity.Distributor;
import com.hilgo.rotax.entity.Driver;
import com.hilgo.rotax.entity.Location;
import com.hilgo.rotax.enums.CargoSituation;
import com.hilgo.rotax.enums.Roles;
import com.hilgo.rotax.repository.CargoRepository;
import com.hilgo.rotax.repository.DistributorRepository;
import com.hilgo.rotax.repository.DriverRepository;
import com.hilgo.rotax.repository.LocationRepository;
import com.hilgo.rotax.repository.ReviewRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import static org.hamcrest.Matchers.is;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class PublicControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private CargoRepository cargoRepository;

    @Autowired
    private DriverRepository driverRepository;

    @Autowired
    private DistributorRepository distributorRepository;

    @Autowired
    private LocationRepository locationRepository;

    @Autowired
    private ReviewRepository reviewRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private Cargo testCargo;
    private final String TRACKING_CODE = "ABC-123";

    @BeforeEach
    void setUp() {
        Driver driver = new Driver();
        driver.setUsername("publictestdriver");
        driver.setPassword(passwordEncoder.encode("password"));
        driver.setFirstName("Test");
        driver.setLastName("Driver");
        driver.setEmail("driver-public@test.com");
        driver.setPhoneNumber("1111111111"); // <-- BU SATIR DA EKLENMELİ
        driver.setRole(Roles.DRIVER);
        driver.setEnabled(true);
        // AYNI ÖNCEKİ TEST GİBİ BU ALANLARI DA EKLE
        driver.setAccountNonExpired(true);
        driver.setAccountNonLocked(true);
        driver.setCredentialsNonExpired(true);
        driverRepository.save(driver);

        Distributor distributor = new Distributor();
        distributor.setUsername("publictestdistributor");
        distributor.setPassword(passwordEncoder.encode("password"));
        distributor.setFirstName("Test");
        distributor.setLastName("Distributor");
        distributor.setEmail("distributor-public@test.com");
        distributor.setPhoneNumber("2222222222"); // <-- BU SATIR DA EKLENMELİ
        distributor.setRole(Roles.DISTRIBUTOR);
        distributor.setEnabled(true);
        // AYNI ÖNCEKİ TEST GİBİ BU ALANLARI DA EKLE
        distributor.setAccountNonExpired(true);
        distributor.setAccountNonLocked(true);
        distributor.setCredentialsNonExpired(true);
        distributorRepository.save(distributor);

        // ... Kargo oluşturma kodu aynı kalacak ...
        Location location = locationRepository.save(new Location());
        testCargo = new Cargo();
        testCargo.setDistributor(distributor);
        testCargo.setDriver(driver);
        testCargo.setSelfLocation(location);
        testCargo.setTargetLocation(location);
        testCargo.setCargoSituation(CargoSituation.PICKED_UP);
        testCargo.setVerificationCode(TRACKING_CODE);
        cargoRepository.save(testCargo);
    }

    @Test
    void trackCargo_ShouldReturnTrackingInfo() throws Exception {
        mockMvc.perform(get("/api/public/track/{trackingCode}", TRACKING_CODE))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.trackingCode", is(TRACKING_CODE)))
                .andExpect(jsonPath("$.status", is("PICKED_UP")));
    }

    @Test
    void addDeliveryNote_ShouldReturnSuccess() throws Exception {
        DeliveryNoteRequest request = new DeliveryNoteRequest();
        request.setNote("Kapıya bırakın.");

        mockMvc.perform(post("/api/public/track/{trackingCode}/note", TRACKING_CODE)
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success", is(true)));

        Cargo updatedCargo;
        updatedCargo = cargoRepository.findById(testCargo.getId()).get();
        assertEquals("Kapıya bırakın.", updatedCargo.getDescription());
    }

    @Test
    void addReview_ShouldReturnSuccess() throws Exception {
        // Review eklemek için kargonun teslim edilmiş olması gerekir
        testCargo.setCargoSituation(CargoSituation.DELIVERED);
        cargoRepository.save(testCargo);

        ReviewDTO request = new ReviewDTO();
        request.setRating(5);
        request.setComment("Great service!");

        mockMvc.perform(post("/api/public/track/{trackingCode}/review", TRACKING_CODE)
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success", is(true)));

        assertEquals(1, reviewRepository.count());
    }

    @Test
    void trackCargo_ShouldReturnNotFound_WhenCargoDoesNotExist() throws Exception {
        mockMvc.perform(get("/api/public/track/INVALID-CODE"))
                .andExpect(status().isNotFound());
    }

    @Test
    void addDeliveryNote_ShouldReturnBadRequest_WhenNoteIsEmpty() throws Exception {
        DeliveryNoteRequest request = new DeliveryNoteRequest();
        request.setNote("");

        mockMvc.perform(post("/api/public/track/{trackingCode}/note", TRACKING_CODE)
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());
    }
}