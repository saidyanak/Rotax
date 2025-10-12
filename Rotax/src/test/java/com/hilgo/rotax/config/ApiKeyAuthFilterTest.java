package com.hilgo.rotax.config;

import com.hilgo.rotax.BaseTest;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.security.core.context.SecurityContextHolder;

import java.io.IOException;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class ApiKeyAuthFilterTest extends BaseTest {

    @Mock
    private HttpServletRequest request;

    @Mock
    private HttpServletResponse response;

    @Mock
    private FilterChain filterChain;

    @InjectMocks
    private ApiKeyAuthFilter apiKeyAuthFilter;

    @BeforeEach
    void setUp() {
        apiKeyAuthFilter = new ApiKeyAuthFilter("X-API-KEY", "test-api-key");
        SecurityContextHolder.clearContext();
    }

    @Test
    void doFilterInternal_ShouldAuthenticate_WhenApiKeyIsValid() throws ServletException, IOException {
        // Arrange
        when(request.getHeader("X-API-KEY")).thenReturn("test-api-key");

        // Act
        apiKeyAuthFilter.doFilterInternal(request, response, filterChain);

        // Assert
        verify(filterChain).doFilter(request, response);
        assertNotNull(SecurityContextHolder.getContext().getAuthentication());
        assertTrue(SecurityContextHolder.getContext().getAuthentication().isAuthenticated());
    }

    @Test
    void doFilterInternal_ShouldNotAuthenticate_WhenApiKeyIsInvalid() throws ServletException, IOException {
        // Arrange
        when(request.getHeader("X-API-KEY")).thenReturn("invalid-api-key");

        // Act
        apiKeyAuthFilter.doFilterInternal(request, response, filterChain);

        // Assert
        verify(filterChain).doFilter(request, response);
        assertNull(SecurityContextHolder.getContext().getAuthentication());
    }

    @Test
    void doFilterInternal_ShouldNotAuthenticate_WhenApiKeyIsMissing() throws ServletException, IOException {
        // Arrange
        when(request.getHeader("X-API-KEY")).thenReturn(null);

        // Act
        apiKeyAuthFilter.doFilterInternal(request, response, filterChain);

        // Assert
        verify(filterChain).doFilter(request, response);
        assertNull(SecurityContextHolder.getContext().getAuthentication());
    }
}