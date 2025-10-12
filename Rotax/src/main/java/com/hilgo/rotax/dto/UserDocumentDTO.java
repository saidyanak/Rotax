package com.hilgo.rotax.dto;

import java.time.LocalDateTime;

import com.hilgo.rotax.enums.DocumentType;
import com.hilgo.rotax.enums.VerificationStatus;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserDocumentDTO {
    private Long id;
    private Long userId;
    private String username;
    private DocumentType documentType;
    private String fileUrl;
    private VerificationStatus verificationStatus;
    private String rejectionReason;
    private LocalDateTime uploadedAt;
}