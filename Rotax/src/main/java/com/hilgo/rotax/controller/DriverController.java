package com.hilgo.rotax.controller;

import com.hilgo.rotax.dto.*;
import com.hilgo.rotax.enums.CargoSituation;
import com.hilgo.rotax.service.DriverService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/api/driver")
@RequiredArgsConstructor
public class DriverController {

    private final DriverService driverService;

    @PutMapping("/status")
    public ResponseEntity<MessageResponse> updateStatus(@Valid @RequestBody DriverStatusUpdateRequest request) {
        driverService.updateDriverStatus(request);
        return ResponseEntity.ok(new MessageResponse("Driver status updated successfully"));
    }

    @GetMapping("/dashboard")
    public ResponseEntity<DriverDashboardResponse> getDashboard() {
        return ResponseEntity.ok(driverService.getDriverDashboard());
    }

    @GetMapping("/offers")
    public ResponseEntity<List<CargoOfferDTO>> getOffers() {
        return ResponseEntity.ok(driverService.getAvailableOffers());
    }

    @PostMapping("/offers/{cargoId}/accept")
    public ResponseEntity<CargoDTO> acceptOffer(@PathVariable Long cargoId) {
        return ResponseEntity.ok(driverService.acceptOffer(cargoId));
    }

    @PutMapping("/cargos/{cargoId}/status/picked-up")
    public ResponseEntity<CargoDTO> markCargoAsPickedUp(@PathVariable Long cargoId) {
        return ResponseEntity.ok(driverService.updateCargoStatus(cargoId, CargoSituation.PICKED_UP));
    }

    @PutMapping("/cargos/{cargoId}/status/delivered")
    public ResponseEntity<CargoDTO> markCargoAsDelivered(@PathVariable Long cargoId) {
        return ResponseEntity.ok(driverService.updateCargoStatus(cargoId, CargoSituation.DELIVERED));
    }
}
