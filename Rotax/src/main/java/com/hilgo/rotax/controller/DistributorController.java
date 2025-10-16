package com.hilgo.rotax.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.hilgo.rotax.dto.CargoDTO;
import com.hilgo.rotax.dto.CreateCargoRequest;
import com.hilgo.rotax.dto.DistributorDashboardResponse;
import com.hilgo.rotax.dto.UserDTO;
import com.hilgo.rotax.dto.ProfileUpdateRequestDTO;
import com.hilgo.rotax.service.DistributorService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/distributor")
@Tag(name = "Distributor API", description = "Dağıtıcı (kargo gönderen firma) operasyonları için endpointler")
@RequiredArgsConstructor
public class DistributorController {

    private final DistributorService distributorService;

    @GetMapping("/dashboard")
    @Operation(summary = "Dağıtıcı dashboard verilerini getirir", description = "Dağıtıcının gönderdiği kargolarla ilgili özet istatistikleri döndürür.")
    public ResponseEntity<DistributorDashboardResponse> getDashboard() {
        return ResponseEntity.ok(distributorService.getDistributorDashboard());
    }

    @PutMapping("/profile")
    @Operation(summary = "Dağıtıcı profil bilgilerini günceller", description = "Giriş yapmış olan dağıtıcının ad, soyad ve telefon gibi kişisel bilgilerini güncellemesini sağlar.")
    public ResponseEntity<UserDTO> updateProfile(@Valid @RequestBody ProfileUpdateRequestDTO request) {
        return ResponseEntity.ok(distributorService.updateProfile(request));
    }

    @PostMapping(value = "/profile/picture", consumes = "multipart/form-data")
    @Operation(summary = "Dağıtıcı profil resmini yükler/günceller", description = "Dağıtıcının profil resmini sisteme yüklemesini sağlar.")
    public ResponseEntity<UserDTO> uploadProfilePicture(@RequestParam("file") MultipartFile file) {
        return ResponseEntity.ok(distributorService.updateProfilePicture(file));
    }

    @PostMapping("/cargos")
    @Operation(summary = "Yeni bir kargo gönderisi oluşturur", description = "Dağıtıcının sisteme yeni bir kargo eklemesini sağlar.")
    public ResponseEntity<CargoDTO> createCargo(@Valid @RequestBody CreateCargoRequest request) {
        return ResponseEntity.ok(distributorService.createCargo(request));
    }

    @GetMapping("/cargos")
    @Operation(summary = "Dağıtıcıya ait tüm kargoları listeler", description = "Giriş yapmış olan dağıtıcının gönderdiği tüm kargoların listesini döndürür.")
    public ResponseEntity<Map<String , Object>> getAllCargos(@RequestParam(defaultValue = "0") int page,
                                                             @RequestParam(defaultValue = "10") int size,
                                                             @RequestParam(defaultValue = "id") String sortBy) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(sortBy));
        Page<CargoDTO> cargoDTOS = distributorService.getAllCargos(pageable);
        Map<String , Object> response = new HashMap<String,Object>();
        response.put("content", cargoDTOS.getContent());
        response.put("totalElements", cargoDTOS.getTotalElements());
        response.put("totalPages", cargoDTOS.getTotalPages());
        response.put("number", cargoDTOS.getNumber());
        response.put("size", cargoDTOS.getSize());
        response.put("currentPage", cargoDTOS.getNumber());
        response.put("pageSize", cargoDTOS.getSize());
        response.put("sort", cargoDTOS.getSort());
        response.put("numberOfElements", cargoDTOS.getNumberOfElements());
        response.put("first", cargoDTOS.isFirst());
        response.put("last", cargoDTOS.isLast());
        return ResponseEntity.ok(response);
    }

    @GetMapping("/cargos/{cargoId}")
    @Operation(summary = "Belirtilen ID'ye sahip kargo detayını getirir", description = "Tek bir kargonun detaylı bilgilerini döndürür.")
    public ResponseEntity<CargoDTO> getCargoById(@PathVariable Long cargoId) {
        return ResponseEntity.ok(distributorService.getCargoById(cargoId));
    }

    @PutMapping("/cargos/{cargoId}/cancel")
    @Operation(summary = "Bir kargoyu iptal eder", description = "Henüz teslimat sürecine başlamamış bir kargonun iptal edilmesini sağlar.")
    public ResponseEntity<CargoDTO> cancelCargo(@PathVariable Long cargoId) {
        return ResponseEntity.ok(distributorService.cancelCargo(cargoId));
    }
}