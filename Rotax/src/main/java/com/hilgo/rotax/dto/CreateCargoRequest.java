package com.hilgo.rotax.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class CreateCargoRequest {
    @NotNull(message = "Self location is required")
    private LocationDTO selfLocation;
    
    @NotNull(message = "Target location is required")
    private LocationDTO targetLocation;
    
    @NotNull(message = "Measure is required")
    private MeasureDTO measure;
    
    @NotBlank(message = "Phone number is required")
    private String phoneNumber;
    
    private String description;
}