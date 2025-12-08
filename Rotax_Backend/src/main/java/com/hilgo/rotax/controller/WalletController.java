package com.hilgo.rotax.controller;

import com.hilgo.rotax.dto.*;
import com.hilgo.rotax.enums.TransactionType;
import com.hilgo.rotax.service.WalletService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/wallet")
@RequiredArgsConstructor
@Tag(name = "Wallet API", description = "Cüzdan ve ödeme işlemleri için endpoint'ler")
@SecurityRequirement(name = "Bearer Authentication")
public class WalletController {

    private final WalletService walletService;

    @GetMapping
    @Operation(summary = "Cüzdan bilgilerini getirir", description = "Mevcut kullanıcının cüzdan bilgilerini (bakiye, toplam kazanç/harcama) döndürür.")
    public ResponseEntity<WalletDTO> getWallet() {
        return ResponseEntity.ok(walletService.getWalletInfo());
    }

    @GetMapping("/summary")
    @Operation(summary = "Cüzdan özetini getirir", description = "Bakiye bilgileri ve son işlemlerle birlikte detaylı özet döndürür.")
    public ResponseEntity<WalletSummaryDTO> getWalletSummary() {
        return ResponseEntity.ok(walletService.getWalletSummary());
    }

    @PostMapping("/deposit")
    @Operation(summary = "Bakiye yükler", 
            description = "Cüzdana bakiye yükler. NOT: Gerçek ödeme entegrasyonu henüz yapılmamıştır, test amaçlı direkt eklenir.")
    public ResponseEntity<TransactionDTO> deposit(@Valid @RequestBody DepositRequest request) {
        return ResponseEntity.ok(walletService.deposit(request));
    }

    @PostMapping("/withdraw")
    @Operation(summary = "Bakiye çekme talebi oluşturur", 
            description = "Sürücülerin kazançlarını çekmesi için talep oluşturur. Admin onayı gerektirir.")
    public ResponseEntity<TransactionDTO> withdraw(@Valid @RequestBody WithdrawRequest request) {
        return ResponseEntity.ok(walletService.withdraw(request));
    }

    @GetMapping("/transactions")
    @Operation(summary = "İşlem geçmişini listeler", description = "Kullanıcının tüm cüzdan işlemlerini sayfalı olarak listeler.")
    public ResponseEntity<Map<String, Object>> getTransactions(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) TransactionType type) {

        Page<TransactionDTO> transactionPage = walletService.getTransactionHistory(page, size, type);

        Map<String, Object> response = new HashMap<>();
        response.put("content", transactionPage.getContent());
        response.put("totalElements", transactionPage.getTotalElements());
        response.put("totalPages", transactionPage.getTotalPages());
        response.put("currentPage", transactionPage.getNumber());
        response.put("pageSize", transactionPage.getSize());

        return ResponseEntity.ok(response);
    }

    @GetMapping("/calculate-price")
    @Operation(summary = "Kargo ücreti hesaplar", description = "Mesafeye göre tahmini kargo ücretini hesaplar.")
    public ResponseEntity<Map<String, Object>> calculatePrice(@RequestParam double distanceKm) {
        Map<String, Object> response = new HashMap<>();
        response.put("distanceKm", distanceKm);
        response.put("estimatedPrice", walletService.calculateCargoPrice(distanceKm));
        response.put("currency", "TRY");
        return ResponseEntity.ok(response);
    }
}
