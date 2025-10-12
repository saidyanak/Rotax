package com.hilgo.rotax.controller;

import com.hilgo.rotax.dto.*;
import com.hilgo.rotax.service.DistributorService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/api/distributor")
@RequiredArgsConstructor
public class DistributorController {

    private final DistributorService distributorService;

    @GetMapping("/dashboard")
    public ResponseEntity<DistributorDashboardResponse> getDashboard() {
        return ResponseEntity.ok(distributorService.getDistributorDashboard());
    }

    @PostMapping("/cargos")
    public ResponseEntity<CargoDTO> createCargo(@Valid @RequestBody CreateCargoRequest request) {
        return ResponseEntity.ok(distributorService.createCargo(request));
    }

    @GetMapping("/cargos")
    public ResponseEntity<List<CargoDTO>> getAllCargos() {
        return ResponseEntity.ok(distributorService.getAllCargos());
    }

    @GetMapping("/cargos/{cargoId}")
    public ResponseEntity<CargoDTO> getCargoById(@PathVariable Long cargoId) {
        return ResponseEntity.ok(distributorService.getCargoById(cargoId));
    }

    @PutMapping("/cargos/{cargoId}/cancel")
    public ResponseEntity<CargoDTO> cancelCargo(@PathVariable Long cargoId) {
        return ResponseEntity.ok(distributorService.cancelCargo(cargoId));
    }
}