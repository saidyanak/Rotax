package com.hilgo.rotax.controller;

import com.hilgo.rotax.dto.DocumentReviewRequest;
import com.hilgo.rotax.dto.UserDocumentDTO;
import com.hilgo.rotax.entity.User;
import com.hilgo.rotax.entity.UserDocument;
import com.hilgo.rotax.enums.DocumentType;
import com.hilgo.rotax.enums.Roles;
import com.hilgo.rotax.enums.VerificationStatus;
import com.hilgo.rotax.exception.ResourceNotFoundException;
import com.hilgo.rotax.repository.UserDocumentRepository;
import com.hilgo.rotax.repository.UserRepository;
import com.hilgo.rotax.service.AdminService;
import com.hilgo.rotax.service.EmailService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Collections;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AdminServiceTest {

    @Mock
    private UserDocumentRepository userDocumentRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private EmailService emailService;

    @InjectMocks
    private AdminService adminService;

    private User testDriver;
    private UserDocument testDocument;

    @BeforeEach
    void setUp() {
        testDriver = User.builder()
                .id(1L)
                .username("testdriver")
                .email("driver@test.com")
                .firstName("Test")
                .role(Roles.DRIVER)
                .enabled(false)
                .build();

        testDocument = UserDocument.builder()
                .id(100L)
                .user(testDriver)
                .documentType(DocumentType.DRIVERS_LICENSE)
                .verificationStatus(VerificationStatus.PENDING)
                .fileUrl("/uploads/license.jpg")
                .build();

        // Kullanıcının belge listesine bu belgeyi ekle
        testDriver.setDocuments(Collections.singletonList(testDocument));
    }

    @Test
    void getPendingDocuments_ShouldReturnListOfPendingDocuments() {
        // Arrange
        when(userDocumentRepository.findByVerificationStatus(VerificationStatus.PENDING))
                .thenReturn(Collections.singletonList(testDocument));

        // Act
        List<UserDocumentDTO> result = adminService.getPendingDocuments();

        // Assert
        assertFalse(result.isEmpty());
        assertEquals(1, result.size());
        assertEquals(VerificationStatus.PENDING, result.get(0).getVerificationStatus());
        verify(userDocumentRepository, times(1)).findByVerificationStatus(VerificationStatus.PENDING);
    }

    @Test
    void approveDocument_ShouldApproveDocumentAndActivateUser_WhenAllDocumentsAreApproved() {
        // Arrange
        when(userDocumentRepository.findById(anyLong())).thenReturn(Optional.of(testDocument));
        when(userDocumentRepository.save(any(UserDocument.class))).thenReturn(testDocument);

        // Act
        UserDocumentDTO result = adminService.approveDocument(100L);

        // Assert
        assertEquals(VerificationStatus.APPROVED, result.getVerificationStatus());
        assertEquals(true, testDriver.getEnabled()); // Kullanıcının aktif edildiğini doğrula
        verify(userDocumentRepository, times(1)).save(any(UserDocument.class));
        verify(userRepository, times(1)).save(testDriver); // Kullanıcının kaydedildiğini doğrula
    }

    @Test
    void approveDocument_ShouldThrowException_WhenDocumentNotFound() {
        // Arrange
        when(userDocumentRepository.findById(anyLong())).thenReturn(Optional.empty());

        // Act & Assert
        assertThrows(ResourceNotFoundException.class, () -> {
            adminService.approveDocument(999L);
        });
        verify(userRepository, never()).save(any()); // Kullanıcı kaydedilmemeli
    }

    @Test
    void rejectDocument_ShouldRejectDocumentAndSendEmail() {
        // Arrange
        DocumentReviewRequest request = new DocumentReviewRequest();
        request.setRejectionReason("Fotoğraf okunaklı değil.");

        when(userDocumentRepository.findById(anyLong())).thenReturn(Optional.of(testDocument));
        when(userDocumentRepository.save(any(UserDocument.class))).thenReturn(testDocument);
        // emailService.send... void olduğu için mock'lamaya gerek yok, sadece çağrıldığını doğrulayacağız.
        doNothing().when(emailService).sendDocumentRejectionEmail(anyString(), anyString(), anyString(), anyString());

        // Act
        UserDocumentDTO result = adminService.rejectDocument(100L, request);

        // Assert
        assertEquals(VerificationStatus.REJECTED, result.getVerificationStatus());
        assertEquals("Fotoğraf okunaklı değil.", result.getRejectionReason());
        assertEquals(false, testDriver.getEnabled()); // Kullanıcı aktif edilmemeli

        verify(userDocumentRepository, times(1)).save(any(UserDocument.class));
        verify(userRepository, never()).save(any()); // Kullanıcı durumu değişmediği için kaydedilmemeli
        verify(emailService, times(1)).sendDocumentRejectionEmail(
                "driver@test.com",
                "Test",
                "DRIVERS_LICENSE",
                "Fotoğraf okunaklı değil."
        );
    }
}