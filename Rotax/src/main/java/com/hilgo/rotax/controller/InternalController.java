package com.hilgo.rotax.controller;

import com.hilgo.rotax.entity.Driver;
import com.hilgo.rotax.enums.DriverStatus;
import com.hilgo.rotax.repository.DriverRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/internal")
@RequiredArgsConstructor
public class InternalController {

    private final DriverRepository driverRepository;

    @GetMapping("/drivers/available")
    public ResponseEntity<List<Driver>> getAvailableDrivers() {
        // This endpoint is for internal use by the Python matching service
        return ResponseEntity.ok(driverRepository.findAllByDriverStatus(DriverStatus.ACTIVE));
    }
}