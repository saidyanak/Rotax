package com.hilgo.rotax.controller;

import com.hilgo.rotax.dto.*;
import com.hilgo.rotax.enums.CargoSituation;
import com.hilgo.rotax.enums.Roles;
import com.hilgo.rotax.service.AdminService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
@Tag(name = "Admin API", description = "Yönetici operasyonları için endpointler")
@SecurityRequirement(name = "Bearer Authentication")
public class AdminController {

    private final AdminService adminService;

    // =============== DASHBOARD ===============

    @GetMapping("/dashboard")
    @Operation(summary = "Admin Dashboard", description = "Sistem genelindeki istatistikleri ve özet bilgileri getirir.")
    public ResponseEntity<AdminDashboardDTO> getDashboard() {
        return ResponseEntity.ok(adminService.getDashboard());
    }

    // =============== USER MANAGEMENT ===============

    @GetMapping("/users")
    @Operation(summary = "Tüm Kullanıcıları Listeler", description = "Sistemdeki tüm kullanıcıları sayfalı olarak listeler. Role göre filtreleme yapılabilir.")
    public ResponseEntity<Map<String, Object>> getAllUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "DESC") String sortDir,
            @RequestParam(required = false) Roles role) {

        Sort sort = sortDir.equalsIgnoreCase("ASC") ? Sort.by(sortBy).ascending() : Sort.by(sortBy).descending();
        Pageable pageable = PageRequest.of(page, size, sort);
        Page<AdminUserDTO> userPage = adminService.getAllUsers(pageable, role);

        Map<String, Object> response = new HashMap<>();
        response.put("content", userPage.getContent());
        response.put("totalElements", userPage.getTotalElements());
        response.put("totalPages", userPage.getTotalPages());
        response.put("currentPage", userPage.getNumber());
        response.put("pageSize", userPage.getSize());

        return ResponseEntity.ok(response);
    }

    @GetMapping("/users/{userId}")
    @Operation(summary = "Kullanıcı Detayı", description = "Belirtilen ID'ye sahip kullanıcının detaylı bilgilerini getirir.")
    public ResponseEntity<AdminUserDTO> getUserById(@PathVariable Long userId) {
        return ResponseEntity.ok(adminService.getUserById(userId));
    }

    @PutMapping("/users/{userId}/toggle-status")
    @Operation(summary = "Kullanıcı Durumunu Değiştir", description = "Kullanıcıyı aktif/pasif yapar.")
    public ResponseEntity<AdminUserDTO> toggleUserStatus(@PathVariable Long userId) {
        return ResponseEntity.ok(adminService.toggleUserStatus(userId));
    }

    @PutMapping("/users/{userId}/toggle-lock")
    @Operation(summary = "Kullanıcı Kilidini Değiştir", description = "Kullanıcı hesabını kilitler veya kilidi açar.")
    public ResponseEntity<AdminUserDTO> toggleUserLock(@PathVariable Long userId) {
        return ResponseEntity.ok(adminService.toggleUserLock(userId));
    }

    // =============== CARGO MANAGEMENT ===============

    @GetMapping("/cargos")
    @Operation(summary = "Tüm Kargoları Listeler", description = "Sistemdeki tüm kargoları sayfalı olarak listeler. Duruma göre filtreleme yapılabilir.")
    public ResponseEntity<Map<String, Object>> getAllCargos(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "DESC") String sortDir,
            @RequestParam(required = false) CargoSituation status) {

        Sort sort = sortDir.equalsIgnoreCase("ASC") ? Sort.by(sortBy).ascending() : Sort.by(sortBy).descending();
        Pageable pageable = PageRequest.of(page, size, sort);
        Page<AdminCargoDTO> cargoPage = adminService.getAllCargos(pageable, status);

        Map<String, Object> response = new HashMap<>();
        response.put("content", cargoPage.getContent());
        response.put("totalElements", cargoPage.getTotalElements());
        response.put("totalPages", cargoPage.getTotalPages());
        response.put("currentPage", cargoPage.getNumber());
        response.put("pageSize", cargoPage.getSize());

        return ResponseEntity.ok(response);
    }

    @GetMapping("/cargos/{cargoId}")
    @Operation(summary = "Kargo Detayı", description = "Belirtilen ID'ye sahip kargonun detaylı bilgilerini getirir.")
    public ResponseEntity<AdminCargoDTO> getCargoById(@PathVariable Long cargoId) {
        return ResponseEntity.ok(adminService.getCargoById(cargoId));
    }

    @PutMapping("/cargos/{cargoId}/cancel")
    @Operation(summary = "Kargoyu İptal Et", description = "Admin yetkisiyle bir kargoyu iptal eder.")
    public ResponseEntity<AdminCargoDTO> cancelCargo(
            @PathVariable Long cargoId,
            @RequestParam String reason) {
        return ResponseEntity.ok(adminService.cancelCargo(cargoId, reason));
    }

    // =============== DOCUMENT MANAGEMENT ===============

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
    public ResponseEntity<UserDocumentDTO> rejectDocument(
            @PathVariable Long documentId,
            @Valid @RequestBody DocumentReviewRequest request) {
        return ResponseEntity.ok(adminService.rejectDocument(documentId, request));
    }

    // =============== TRANSACTION MANAGEMENT ===============

    @GetMapping("/withdrawals/pending")
    @Operation(summary = "Bekleyen Çekim Taleplerini Listeler", description = "Onay bekleyen bakiye çekme taleplerini listeler.")
    public ResponseEntity<Map<String, Object>> getPendingWithdrawals(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {

        Pageable pageable = PageRequest.of(page, size);
        Page<TransactionDTO> withdrawalPage = adminService.getPendingWithdrawals(pageable);

        Map<String, Object> response = new HashMap<>();
        response.put("content", withdrawalPage.getContent());
        response.put("totalElements", withdrawalPage.getTotalElements());
        response.put("totalPages", withdrawalPage.getTotalPages());
        response.put("currentPage", withdrawalPage.getNumber());

        return ResponseEntity.ok(response);
    }

    @PostMapping("/withdrawals/{transactionId}/approve")
    @Operation(summary = "Çekim Talebini Onayla", description = "Bekleyen bir çekim talebini onaylar.")
    public ResponseEntity<TransactionDTO> approveWithdrawal(@PathVariable Long transactionId) {
        return ResponseEntity.ok(adminService.approveWithdrawal(transactionId));
    }

    @PostMapping("/withdrawals/{transactionId}/reject")
    @Operation(summary = "Çekim Talebini Reddet", description = "Bekleyen bir çekim talebini reddeder ve bakiyeyi iade eder.")
    public ResponseEntity<TransactionDTO> rejectWithdrawal(
            @PathVariable Long transactionId,
            @RequestParam String reason) {
        return ResponseEntity.ok(adminService.rejectWithdrawal(transactionId, reason));
    }
}