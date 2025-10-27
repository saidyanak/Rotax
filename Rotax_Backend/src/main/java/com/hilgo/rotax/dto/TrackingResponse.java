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
public class TrackingResponse {
    private String trackingCode;
    private CargoSituation status;
    private LocationDTO currentLocation;
    private LocationDTO destinationLocation;
    private String driverName;
    private String driverPhone;
    private Double estimatedTimeOfArrival; // in minutes
    private LocalDateTime deliveryTime;
    private String deliveryNote;
}