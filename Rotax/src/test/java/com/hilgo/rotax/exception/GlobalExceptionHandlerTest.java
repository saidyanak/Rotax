package com.hilgo.rotax.exception;

import com.hilgo.rotax.BaseTest;
import com.hilgo.rotax.dto.MessageResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;

import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.when;

class GlobalExceptionHandlerTest extends BaseTest {

    @Mock
    private MethodArgumentNotValidException methodArgumentNotValidException;

    @Mock
    private BindingResult bindingResult;

    @Mock
    private FieldError fieldError;

    @InjectMocks
    private GlobalExceptionHandler globalExceptionHandler;

    @BeforeEach
    void setUp() {
        when(methodArgumentNotValidException.getBindingResult()).thenReturn(bindingResult);
    }

    @Test
    void handleResourceNotFoundException_ShouldReturnNotFound() {
        // Arrange
        ResourceNotFoundException ex = new ResourceNotFoundException("Driver", "id", "1");

        // Act
        ResponseEntity<MessageResponse> response = globalExceptionHandler.handleResourceNotFoundException(ex);

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("Driver not found with id: 1", response.getBody().getMessage());
        assertFalse(response.getBody().isSuccess());
    }

    @Test
    void handleBadRequestException_ShouldReturnBadRequest() {
        // Arrange
        BadRequestException ex = new BadRequestException("Invalid request");

        // Act
        ResponseEntity<MessageResponse> response = globalExceptionHandler.handleBadRequestException(ex);

        // Assert
        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("Invalid request", response.getBody().getMessage());
        assertFalse(response.getBody().isSuccess());
    }

    @Test
    void handleValidationExceptions_ShouldReturnBadRequest() {
        // Arrange
        FieldError fieldError1 = new FieldError("object", "rating", "Rating must be between 1 and 5");
        FieldError fieldError2 = new FieldError("object", "comment", "Comment is required");

        when(bindingResult.getAllErrors()).thenReturn(List.of(fieldError1, fieldError2));

        // Act
        ResponseEntity<Map<String, String>> response = globalExceptionHandler.handleValidationExceptions(methodArgumentNotValidException);

        // Assert
        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals(2, response.getBody().size());
        assertEquals("Rating must be between 1 and 5", response.getBody().get("rating"));
        assertEquals("Comment is required", response.getBody().get("comment"));
    }

    @Test
    void handleGenericException_ShouldReturnInternalServerError() {
        // Arrange
        RuntimeException ex = new RuntimeException("Unexpected error");

        // Act
        ResponseEntity<MessageResponse> response = globalExceptionHandler.handleGenericException(ex);

        // Assert
        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody().getMessage().contains("Unexpected error"));
        assertFalse(response.getBody().isSuccess());
    }

    @Test
    void handleAccessDeniedException_ShouldReturnForbidden() {
        // Arrange
        org.springframework.security.access.AccessDeniedException ex =
                new org.springframework.security.access.AccessDeniedException("Access denied");

        // Act
        ResponseEntity<MessageResponse> response = globalExceptionHandler.handleAccessDeniedException(ex);

        // Assert
        assertEquals(HttpStatus.FORBIDDEN, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("You don't have permission to access this resource", response.getBody().getMessage());
        assertFalse(response.getBody().isSuccess());
    }

    @Test
    void handleBadCredentialsException_ShouldReturnUnauthorized() {
        // Arrange
        org.springframework.security.authentication.BadCredentialsException ex =
                new org.springframework.security.authentication.BadCredentialsException("Bad credentials");

        // Act
        ResponseEntity<MessageResponse> response = globalExceptionHandler.handleBadCredentialsException(ex);

        // Assert
        assertEquals(HttpStatus.UNAUTHORIZED, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("Invalid username or password", response.getBody().getMessage());
        assertFalse(response.getBody().isSuccess());
    }
}