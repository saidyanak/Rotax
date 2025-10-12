package com.hilgo.rotax.controller;

import com.hilgo.rotax.dto.*;
import com.hilgo.rotax.service.PublicService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/public")
@RequiredArgsConstructor
public class PublicController {

    private final PublicService publicService;

    @GetMapping("/track/{token}")
    public ResponseEntity<TrackingResponse> trackCargo(@PathVariable String token) {
        return ResponseEntity.ok(publicService.trackCargo(token));
    }

    @PostMapping("/track/{token}/notes")
    public ResponseEntity<MessageResponse> addDeliveryNote(
            @PathVariable String token,
            @Valid @RequestBody DeliveryNoteRequest request) {
        return ResponseEntity.ok(publicService.addDeliveryNote(token, request));
    }

    @PostMapping("/review/{token}")
    public ResponseEntity<MessageResponse> addReview(
            @PathVariable String token,
            @Valid @RequestBody ReviewDTO reviewDTO) {
        return ResponseEntity.ok(publicService.addReview(token, reviewDTO));
    }
}