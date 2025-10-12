package com.hilgo.rotax.exception;

import com.hilgo.rotax.BaseTest;
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

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
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
        ResponseEntity<Map<String, String>> response = globalExceptionHandler.handleResourceNotFoundException(ex);

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
        assertEquals("Driver not found with id: 1", response.getBody().get("message"));
    }

    @Test
    void handleBadRequestException_ShouldReturnBadRequest() {
        // Arrange
        BadRequestException ex = new BadRequestException("Invalid request");

        // Act
        ResponseEntity<Map<String, String>> response = globalExceptionHandler.handleBadRequestException(ex);

        // Assert
        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertEquals("Invalid request", response.getBody().get("message"));
    }

    @Test
    void handleMethodArgumentNotValid_ShouldReturnBadRequest() {
        // Arrange
        when(bindingResult.getFieldErrors()).thenReturn(List.of(fieldError));
        when(fieldError.getField()).thenReturn("rating");
        when(fieldError.getDefaultMessage()).thenReturn("Rating must be between 1 and 5");

        // Act
        ResponseEntity<Map<String, String>> response = globalExceptionHandler.handleMethodArgumentNotValid(methodArgumentNotValidException);

        // Assert
        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertTrue(response.getBody().get("message").contains("rating: Rating must be between 1 and 5"));
    }

    @Test
    void handleGenericException_ShouldReturnInternalServerError() {
        // Arrange
        RuntimeException ex = new RuntimeException("Unexpected error");

        // Act
        ResponseEntity<Map<String, String>> response = globalExceptionHandler.handleGenericException(ex);

        // Assert
        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, response.getStatusCode());
        assertEquals("Unexpected error", response.getBody().get("message"));
    }
}