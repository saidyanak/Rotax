package com.hilgo.rotax.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class LocationDTO {
    private Double latitude;
    private Double longitude;
    private String address;
    private String city;
    private String district;
    private String postalCode;
}