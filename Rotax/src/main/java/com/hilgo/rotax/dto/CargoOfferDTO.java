package com.hilgo.rotax.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class CargoOfferDTO {
    private Long cargoId;
    private LocationDTO pickupLocation;
    private LocationDTO deliveryLocation;
    private Double distanceToPickup; // in kilometers
    private Double totalDistance; // in kilometers
    private Double estimatedEarning; // in currency
    private MeasureDTO measure;
    private String distributorName;
}