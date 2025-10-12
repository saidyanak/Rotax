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
public class DistributorDashboardResponse {
    private Long distributorId;
    private String distributorName;
    private Integer totalCargos;
    private Integer activeCargos;
    private Integer deliveredCargos;
    private List<CargoDTO> currentCargos;
    private List<CargoDTO> recentCargos;
}