package com.hilgo.rotax.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.hilgo.rotax.dto.CargoDTO;
import com.hilgo.rotax.dto.CargoOfferDTO;
import com.hilgo.rotax.dto.DriverDashboardResponse;
import com.hilgo.rotax.dto.DriverStatusUpdateRequest;
import com.hilgo.rotax.dto.MessageResponse;
import com.hilgo.rotax.enums.CargoSituation;
import com.hilgo.rotax.service.DriverService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/driver")
@Tag(name = "Driver API", description = "Sürücü operasyonları için endpointler")
@RequiredArgsConstructor
public class DriverController {

    private final DriverService driverService;

    @PutMapping("/status")
    @Operation(summary = "Sürücü durumunu ve konumunu günceller", description = "Sürücünün anlık durumunu (ACTIVE, OFFLINE vb.) ve GPS konumunu sisteme bildirir.")
    public ResponseEntity<MessageResponse> updateStatus(@Valid @RequestBody DriverStatusUpdateRequest request) {
        driverService.updateDriverStatus(request);
        return ResponseEntity.ok(new MessageResponse("Driver status updated successfully", true));
    }

    @GetMapping("/dashboard")
    @Operation(summary = "Sürücü dashboard verilerini getirir", description = "Sürücünün kazanç, puan, aktif ve son teslimatlar gibi özet bilgilerini döndürür.")
    public ResponseEntity<DriverDashboardResponse> getDashboard() {
        return ResponseEntity.ok(driverService.getDriverDashboard());
    }

    @GetMapping("/offers")
    @Operation(summary = "Mevcut kargo tekliflerini listeler", description = "Sürücünün konumuna ve durumuna göre alabileceği uygun kargo tekliflerini listeler.")
    public ResponseEntity<List<CargoOfferDTO>> getOffers() {
        return ResponseEntity.ok(driverService.getAvailableOffers());
    }

    @PostMapping("/offers/{cargoId}/accept")
    @Operation(summary = "Bir kargo teklifini kabul eder", description = "Sürücünün bir kargo teklifini kabul ederek teslimat sürecini başlatmasını sağlar.")
    public ResponseEntity<CargoDTO> acceptOffer(@PathVariable Long cargoId) {
        return ResponseEntity.ok(driverService.acceptOffer(cargoId));
    }

    @PutMapping("/cargos/{cargoId}/status/picked-up")
    @Operation(summary = "Kargoyu 'Teslim Alındı' olarak işaretler", description = "Sürücünün dağıtıcıdan kargoyu teslim aldığını sisteme bildirir.")
    public ResponseEntity<CargoDTO> markCargoAsPickedUp(@PathVariable Long cargoId) {
        return ResponseEntity.ok(driverService.updateCargoStatus(cargoId, CargoSituation.PICKED_UP));
    }

    @PutMapping("/cargos/{cargoId}/status/delivered")
    @Operation(summary = "Kargoyu 'Teslim Edildi' olarak işaretler", description = "Sürücünün kargoyu alıcıya teslim ettiğini sisteme bildirir.")
    public ResponseEntity<CargoDTO> markCargoAsDelivered(@PathVariable Long cargoId) {
        return ResponseEntity.ok(driverService.updateCargoStatus(cargoId, CargoSituation.DELIVERED));
    }
}
