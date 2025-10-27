package com.hilgo.rotax.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.hilgo.rotax.entity.Driver;
import com.hilgo.rotax.enums.DriverStatus;
import com.hilgo.rotax.repository.DriverRepository;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/internal")
@Tag(name = "Internal API", description = "Servisler arası (M2M) iletişim için kullanılan endpointler. Sadece API Key ile erişilebilir.")
@RequiredArgsConstructor
public class InternalController {

    private final DriverRepository driverRepository;

    @GetMapping("/drivers/available")
    @Operation(summary = "Uygun sürücüleri listeler", description = "Eşleştirme servisi (Python) tarafından kullanılmak üzere, durumu 'ACTIVE' olan sürücülerin listesini döndürür.")
    public ResponseEntity<List<Driver>> getAvailableDrivers() {
        // This endpoint is for internal use by the Python matching service
        return ResponseEntity.ok(driverRepository.findAllByDriverStatus(DriverStatus.ACTIVE));
    }
}