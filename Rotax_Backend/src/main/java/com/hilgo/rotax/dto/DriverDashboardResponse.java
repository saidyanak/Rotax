package com.hilgo.rotax.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class DriverDashboardResponse {
    private Long driverId;
    private String driverName;
    private Double averageRating;
    private Integer totalDeliveries;
    private Integer activeDeliveries;
    private List<CargoDTO> currentCargos;
    private List<CargoDTO> recentCargos;
}