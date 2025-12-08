package com.hilgo.rotax.dto.messaging;

import com.hilgo.rotax.enums.CargoSituation;
import com.hilgo.rotax.enums.Size;
import lombok.*;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * Kargo eşleştirme için Python service'e gönderilecek mesaj
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CargoMatchingMessage implements Serializable {

    private Long cargoId;
    
    // Alım noktası
    private Double pickupLatitude;
    private Double pickupLongitude;
    private String pickupCity;
    private String pickupDistrict;
    
    // Teslimat noktası
    private Double deliveryLatitude;
    private Double deliveryLongitude;
    private String deliveryCity;
    private String deliveryDistrict;
    
    // Kargo özellikleri
    private Double weight;
    private Size size;
    
    // Distributor bilgisi
    private Long distributorId;
    private String distributorName;
    
    // Zaman bilgisi
    private LocalDateTime createdAt;
    private LocalDateTime expiresAt; // Bu zamana kadar eşleşmezse expire olur
    
    // Ücret bilgisi
    private Double estimatedPrice;
}
