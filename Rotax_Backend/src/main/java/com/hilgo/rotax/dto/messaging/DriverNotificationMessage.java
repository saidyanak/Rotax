package com.hilgo.rotax.dto.messaging;

import lombok.*;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * Sürücüye gönderilecek bildirim mesajı
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DriverNotificationMessage implements Serializable {

    private Long driverId;
    private String driverUsername;
    
    private String title;
    private String body;
    
    private String notificationType; // CARGO_OFFER, CARGO_ASSIGNED, DELIVERY_REMINDER vs.
    
    // İlgili kargo bilgisi (varsa)
    private Long cargoId;
    
    // Ek veri (frontend'in kullanacağı)
    private String actionUrl;
    private String imageUrl;
    
    private LocalDateTime createdAt;
}
