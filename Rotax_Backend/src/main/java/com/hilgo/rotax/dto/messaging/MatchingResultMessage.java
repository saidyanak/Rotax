package com.hilgo.rotax.dto.messaging;

import lombok.*;

import java.io.Serializable;
import java.util.List;

/**
 * Python matching service'den gelen eşleşme sonucu
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MatchingResultMessage implements Serializable {

    private Long cargoId;
    
    private boolean matched;
    
    // Eşleşen sürücüler (öncelik sırasına göre)
    private List<MatchedDriver> matchedDrivers;
    
    private String message;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MatchedDriver implements Serializable {
        private Long driverId;
        private String driverName;
        private Double distanceToPickup; // km
        private Double score; // Eşleştirme skoru (0-100)
    }
}
