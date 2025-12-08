package com.hilgo.rotax.dto;

import com.hilgo.rotax.enums.CargoSituation;
import lombok.*;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AdminCargoDTO {
    private Long id;
    private String trackingCode;
    private CargoSituation cargoSituation;
    
    // Lokasyonlar
    private String pickupAddress;
    private String pickupCity;
    private String deliveryAddress;
    private String deliveryCity;
    
    // Distributor bilgisi
    private Long distributorId;
    private String distributorName;
    private String distributorEmail;
    
    // Driver bilgisi
    private Long driverId;
    private String driverName;
    private String driverPhone;
    
    // Alıcı bilgisi
    private String recipientPhone;
    
    // Zamanlar
    private LocalDateTime createdAt;
    private LocalDateTime takingTime;
    private LocalDateTime deliveredTime;
    
    // Kargo özellikleri
    private Double weight;
    private String size;
}
