package com.hilgo.rotax.controller;

import com.hilgo.rotax.dto.DocumentReviewRequest;
import com.hilgo.rotax.dto.UserDocumentDTO;
import com.hilgo.rotax.service.AdminService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
@Tag(name = "Admin API", description = "Yönetici operasyonları için endpointler")
@SecurityRequirement(name = "Bearer Authentication")
public class AdminController {

    @Autowired
    private final AdminService adminService;

    @GetMapping("/documents/pending")
    @Operation(summary = "Onay Bekleyen Belgeleri Listeler", description = "Sistemdeki tüm 'PENDING' durumundaki kullanıcı belgelerini getirir.")
    public ResponseEntity<List<UserDocumentDTO>> getPendingDocuments() {
        return ResponseEntity.ok(adminService.getPendingDocuments());
    }

    @PostMapping("/documents/{documentId}/approve")
    @Operation(summary = "Bir Belgeyi Onaylar", description = "Belirtilen ID'ye sahip belgeyi 'APPROVED' durumuna geçirir.")
    public ResponseEntity<UserDocumentDTO> approveDocument(@PathVariable Long documentId) {
        return ResponseEntity.ok(adminService.approveDocument(documentId));
    }

    @PostMapping("/documents/{documentId}/reject")
    @Operation(summary = "Bir Belgeyi Reddeder", description = "Belirtilen ID'ye sahip belgeyi 'REJECTED' durumuna geçirir ve reddetme sebebini kaydeder.")
    public ResponseEntity<UserDocumentDTO> rejectDocument(@PathVariable Long documentId, @Valid @RequestBody DocumentReviewRequest request) {
        return ResponseEntity.ok(adminService.rejectDocument(documentId, request));
    }
}