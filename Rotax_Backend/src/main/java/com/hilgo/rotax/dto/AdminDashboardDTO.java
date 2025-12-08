package com.hilgo.rotax.dto;

import lombok.*;

import java.math.BigDecimal;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AdminDashboardDTO {
    
    // Kullanıcı istatistikleri
    private Long totalUsers;
    private Long totalDrivers;
    private Long totalDistributors;
    private Long activeDrivers;
    private Long pendingVerifications;
    
    // Kargo istatistikleri
    private Long totalCargos;
    private Long activeCargos;
    private Long deliveredCargos;
    private Long cancelledCargos;
    
    // Finansal istatistikler
    private BigDecimal totalRevenue;         // Toplam gelir (komisyonlar)
    private BigDecimal totalTransactions;    // Toplam işlem hacmi
    private BigDecimal pendingWithdrawals;   // Bekleyen çekim talepleri
    
    // Son 7 gün istatistikleri
    private Map<String, Long> cargosPerDay;
    private Map<String, Long> newUsersPerDay;
    
    // Son aktiviteler
    private java.util.List<RecentActivityDTO> recentActivities;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RecentActivityDTO {
        private String type;
        private String description;
        private String timestamp;
        private Long relatedId;
    }
}
