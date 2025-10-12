package com.hilgo.rotax.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.hilgo.rotax.dto.DeliveryNoteRequest;
import com.hilgo.rotax.dto.MessageResponse;
import com.hilgo.rotax.dto.ReviewDTO;
import com.hilgo.rotax.dto.TrackingResponse;
import com.hilgo.rotax.service.PublicService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/public")
@Tag(name = "Public API", description = "Son kullanıcılar (kargo alıcıları) için herkese açık endpointler.")
@RequiredArgsConstructor
public class PublicController {

    private final PublicService publicService;

    @GetMapping("/track/{trackingCode}")
    @Operation(summary = "Kargo takip bilgilerini getirir", description = "Verilen takip kodu ile kargonun anlık durumunu, sürücü konumunu ve tahmini varış süresini döndürür.")
    public ResponseEntity<TrackingResponse> trackCargo(@PathVariable String trackingCode) {
        return ResponseEntity.ok(publicService.trackCargo(trackingCode));
    }

    @PostMapping("/track/{trackingCode}/note")
    @Operation(summary = "Kargo için teslimat notu ekler", description = "Son kullanıcının kargo için 'Komşuma bırak' gibi bir teslimat notu eklemesini sağlar.")
    public ResponseEntity<MessageResponse> addDeliveryNote(
            @PathVariable String trackingCode,
            @Valid @RequestBody DeliveryNoteRequest request) {
        return ResponseEntity.ok(publicService.addDeliveryNote(trackingCode, request));
    }

    @PostMapping("/track/{trackingCode}/review")
    @Operation(summary = "Sürücü için yorum ve puan ekler", description = "Teslimat tamamlandıktan sonra son kullanıcının sürücüye yorum ve puan vermesini sağlar.")
    public ResponseEntity<MessageResponse> addReview(
            @PathVariable String trackingCode,
            @Valid @RequestBody ReviewDTO reviewDTO) {
        return ResponseEntity.ok(publicService.addReview(trackingCode, reviewDTO));
    }
}