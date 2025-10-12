package com.hilgo.rotax.dto;

import com.hilgo.rotax.enums.CargoSituation;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class CargoDTO {
    private Long id;
    private LocationDTO selfLocation;
    private LocationDTO targetLocation;
    private MeasureDTO measure;
    private CargoSituation cargoSituation;
    private String phoneNumber;
    private String description;
    private LocalDateTime takingTime;
    private LocalDateTime deliveredTime;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Long distributorId;
    private Long driverId;
    private String driverName;
    private String distributorName;
}