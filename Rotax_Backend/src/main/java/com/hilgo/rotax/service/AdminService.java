package com.hilgo.rotax.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.hilgo.rotax.dto.DocumentReviewRequest;
import com.hilgo.rotax.dto.UserDocumentDTO;
import com.hilgo.rotax.entity.User;
import com.hilgo.rotax.entity.UserDocument;
import com.hilgo.rotax.enums.Roles;
import com.hilgo.rotax.enums.VerificationStatus;
import com.hilgo.rotax.exception.ResourceNotFoundException;
import com.hilgo.rotax.repository.UserDocumentRepository;
import com.hilgo.rotax.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class AdminService {

    private final UserDocumentRepository userDocumentRepository;
    private final UserRepository userRepository;
    private final EmailService emailService;

    /**
     * Onay bekleyen tüm belgeleri listeler.
     * @return Onay bekleyen belgelerin DTO listesi.
     */
    @Transactional(readOnly = true)
    public List<UserDocumentDTO> getPendingDocuments() {
        return userDocumentRepository.findByVerificationStatus(VerificationStatus.PENDING)
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Bir belgeyi onaylar.
     * @param documentId Onaylanacak belgenin ID'si.
     * @return Güncellenmiş belgenin DTO'su.
     */
    @Transactional
    public UserDocumentDTO approveDocument(Long documentId) {
        UserDocument document = userDocumentRepository.findById(documentId)
                .orElseThrow(() -> new ResourceNotFoundException("UserDocument", "id", documentId));

        document.setVerificationStatus(VerificationStatus.APPROVED);
        document.setVerifiedAt(LocalDateTime.now());
        document.setRejectionReason(null);

        UserDocument savedDocument = userDocumentRepository.save(document);
        log.info("Belge ID {} onaylandı. Kullanıcı: {}", documentId, savedDocument.getUser().getUsername());

        // Kullanıcının tüm belgelerinin onaylanıp onaylanmadığını kontrol et ve gerekirse aktive et
        checkAndActivateUser(savedDocument.getUser());

        return convertToDTO(savedDocument);
    }

    private void checkAndActivateUser(User user) {
        // Sadece belirli roller için belge onayı sonrası aktivasyon yapalım.
        // Şimdilik sadece DRIVER için bu kuralı uyguluyoruz.
        if (user.getRole() == Roles.DRIVER) {
            List<UserDocument> documents = user.getDocuments();

            // Eğer hiç belgesi yoksa veya belgelerden en az biri onaylanmamışsa işlem yapma.
            if (documents.isEmpty() || documents.stream().anyMatch(doc -> doc.getVerificationStatus() != VerificationStatus.APPROVED)) {
                return;
            }

            if (!user.getEnabled()) {
                user.setEnabled(true);
                userRepository.save(user);
                log.info("Tüm belgeler onaylandı. Kullanıcı hesabı aktive edildi: {}", user.getUsername());
            }
        }
    }

    /**
     * Bir belgeyi reddeder.
     * @param documentId Reddedilecek belgenin ID'si.
     * @param request Reddetme sebebini içeren DTO.
     * @return Güncellenmiş belgenin DTO'su.
     */
    @Transactional
    public UserDocumentDTO rejectDocument(Long documentId, DocumentReviewRequest request) {
        UserDocument document = userDocumentRepository.findById(documentId)
                .orElseThrow(() -> new ResourceNotFoundException("UserDocument", "id", documentId));

        document.setVerificationStatus(VerificationStatus.REJECTED);
        document.setVerifiedAt(LocalDateTime.now());
        document.setRejectionReason(request.getRejectionReason());

        UserDocument savedDocument = userDocumentRepository.save(document);
        log.warn("Belge ID {} reddedildi. Sebep: {}", documentId, request.getRejectionReason());

        // Kullanıcıya reddedilme sebebini e-posta ile bildir
        User user = savedDocument.getUser();
        emailService.sendDocumentRejectionEmail(
                user.getEmail(),
                user.getFirstName(),
                savedDocument.getDocumentType().toString(), // Enum'u String'e çeviriyoruz
                request.getRejectionReason());

        return convertToDTO(savedDocument);
    }

    private UserDocumentDTO convertToDTO(UserDocument document) {
        User user = document.getUser();
        return UserDocumentDTO.builder()
                .id(document.getId())
                .userId(user.getId())
                .username(user.getUsername())
                .documentType(document.getDocumentType())
                .fileUrl(document.getFileUrl())
                .verificationStatus(document.getVerificationStatus())
                .rejectionReason(document.getRejectionReason())
                .uploadedAt(document.getUploadedAt())
                .build();
    }
}