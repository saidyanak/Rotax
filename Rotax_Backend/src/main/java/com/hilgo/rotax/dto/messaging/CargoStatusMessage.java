package com.hilgo.rotax.dto.messaging;

import com.hilgo.rotax.enums.CargoSituation;
import lombok.*;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * Kargo durum değişikliği mesajı
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CargoStatusMessage implements Serializable {

    private Long cargoId;
    private CargoSituation previousStatus;
    private CargoSituation newStatus;
    
    private Long distributorId;
    private Long driverId;
    
    private String trackingCode;
    
    private LocalDateTime updatedAt;
    
    // Ek bilgiler
    private String message;
}
