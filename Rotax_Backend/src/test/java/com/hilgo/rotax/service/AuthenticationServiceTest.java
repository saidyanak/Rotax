package com.hilgo.rotax.service;

import com.hilgo.rotax.dto.AuthResponse;
import com.hilgo.rotax.dto.LoginRequest;
import com.hilgo.rotax.dto.RegisterRequest;
import com.hilgo.rotax.entity.User;
import com.hilgo.rotax.enums.Roles;
import com.hilgo.rotax.repository.PasswordResetTokenRepository;
import com.hilgo.rotax.repository.UserDocumentRepository;
import com.hilgo.rotax.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.multipart.MultipartFile;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthenticationServiceTest {

    @Mock
    private UserRepository userRepository;
    @Mock
    private PasswordEncoder passwordEncoder;
    @Mock
    private JwtService jwtService;
    @Mock
    private AuthenticationManager authenticationManager;
    @Mock
    private PasswordResetTokenRepository passwordResetTokenRepository;
    @Mock
    private EmailService emailService;
    @Mock
    private FileStorageService fileStorageService;
    @Mock
    private UserDocumentRepository userDocumentRepository;

    @InjectMocks
    private AuthenticationService authenticationService;

    private RegisterRequest registerRequest;

    @BeforeEach
    void setUp() {
        registerRequest = RegisterRequest.builder()
                .username("newuser")
                .email("newuser@test.com")
                .password("password123")
                .firstName("New").lastName("User")
                .phoneNumber("1234567890")
                .roles(Roles.DRIVER)
                .build();
    }

    @Test
    void register_ShouldCreateUserSuccessfully() {
        // Arrange
        when(userRepository.existsByUsername(anyString())).thenReturn(false);
        when(userRepository.existsByEmail(anyString())).thenReturn(false);
        when(passwordEncoder.encode(anyString())).thenReturn("encodedPassword");
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(jwtService.generateToken(any(User.class))).thenReturn("dummy-jwt-token");

        // Act
        AuthResponse response = authenticationService.register(registerRequest, null);

        // Assert
        assertNotNull(response);
        assertEquals("dummy-jwt-token", response.getToken());
        assertEquals("newuser", response.getUsername());
        verify(userRepository, times(1)).save(any(User.class));
        verify(emailService, times(1)).sendRegistrationConfirmationEmail(anyString(), anyString());
    }

    @Test
    void register_ShouldSaveDocuments_WhenDocumentsAreProvided() {
        // Arrange
        when(userRepository.existsByUsername(anyString())).thenReturn(false);
        when(userRepository.existsByEmail(anyString())).thenReturn(false);
        when(passwordEncoder.encode(anyString())).thenReturn("encodedPassword");
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(fileStorageService.storeFile(any(MultipartFile.class))).thenReturn("http://localhost/uploads/doc.pdf");

        MultipartFile[] documents = {new MockMultipartFile("doc", "ehliyet.pdf", "application/pdf", "content".getBytes())};

        // Act
        authenticationService.register(registerRequest, documents);

        // Assert
        verify(fileStorageService, times(1)).storeFile(any(MultipartFile.class));
        verify(userDocumentRepository, times(1)).save(any());
    }

    @Test
    void register_ShouldThrowException_WhenUsernameExists() {
        // Arrange
        when(userRepository.existsByUsername(anyString())).thenReturn(true);

        // Act & Assert
        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> {
            authenticationService.register(registerRequest, null);
        });
        assertEquals("Bu kullanıcı adı zaten kullanılıyor", exception.getMessage());
    }

    @Test
    void login_ShouldReturnAuthResponse_WhenCredentialsAreValid() {
        // Arrange
        LoginRequest loginRequest = new LoginRequest("testuser", "password");
        User user = User.builder().username("testuser").build();
        Authentication authentication = mock(Authentication.class);

        when(userRepository.findByUsername(anyString())).thenReturn(Optional.of(user));
        when(authenticationManager.authenticate(any())).thenReturn(authentication);
        when(jwtService.generateToken(user)).thenReturn("dummy-jwt-token");

        // Act
        AuthResponse response = authenticationService.login(loginRequest);

        // Assert
        assertNotNull(response);
        assertEquals("dummy-jwt-token", response.getToken());
        verify(authenticationManager, times(1)).authenticate(any(UsernamePasswordAuthenticationToken.class));
    }
}
