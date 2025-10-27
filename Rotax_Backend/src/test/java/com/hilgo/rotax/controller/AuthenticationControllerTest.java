package com.hilgo.rotax.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.hilgo.rotax.dto.LoginRequest;
import com.hilgo.rotax.dto.RegisterRequest;
import com.hilgo.rotax.entity.User;
import com.hilgo.rotax.enums.Roles;
import com.hilgo.rotax.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@Transactional // Her testten sonra veritabanı değişikliklerini geri al
class AuthenticationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @BeforeEach
    void setUp() {
        // userRepository.deleteAll(); // <-- BU SATIRI SİL VEYA YORUMA AL

        // Login testi için önceden bir kullanıcı oluştur
        User user = User.builder()
                .username("testuser")
                .email("testuser@rotax.com")
                .password(passwordEncoder.encode("password123"))
                .firstName("Test").lastName("User")
                .phoneNumber("5555555555")
                .role(Roles.DISTRIBUTOR)
                .enabled(true)
                .accountNonExpired(true)
                .accountNonLocked(true)
                .credentialsNonExpired(true)
                .build();
        userRepository.save(user);
    }

    @Transactional
    @Test
    void register_ShouldCreateUserAndReturnToken_WhenRequestIsValid() throws Exception {
        // Arrange
        RegisterRequest registerRequest = RegisterRequest.builder()
                .username("newdriver")
                .email("newdriver@rotax.com")
                .password("password123")
                .firstName("New").lastName("Driver")
                .phoneNumber("3333333333")
                .roles(Roles.DRIVER)
                .tc("12345678901")
                .build();

        MockMultipartFile requestPart = new MockMultipartFile(
                "request",
                "",
                MediaType.APPLICATION_JSON_VALUE,
                objectMapper.writeValueAsBytes(registerRequest)
        );

        MockMultipartFile documentPart = new MockMultipartFile(
                "documents",
                "ehliyet.pdf",
                MediaType.APPLICATION_PDF_VALUE,
                "dummy pdf content".getBytes()
        );

        // Act & Assert
        mockMvc.perform(multipart("/api/auth/register")
                        .file(requestPart)
                        .file(documentPart))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.token", notNullValue()))
                .andExpect(jsonPath("$.username", is("newdriver")));

        // Veritabanından kontrol et
        assertTrue(userRepository.findByUsername("newdriver").isPresent());
    }

    @Transactional
    @Test
    void login_ShouldReturnToken_WhenCredentialsAreValid() throws Exception {
        // Arrange
        LoginRequest loginRequest = new LoginRequest("testuser", "password123");

        // Act & Assert
        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token", notNullValue()))
                .andExpect(jsonPath("$.username", is("testuser")));
    }

    @Transactional
    @Test
    void login_ShouldReturnUnauthorized_WhenPasswordIsInvalid() throws Exception {
        // Arrange
        LoginRequest loginRequest = new LoginRequest("testuser", "wrongpassword");

        // Act & Assert
        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isUnauthorized());
    }
}