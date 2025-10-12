package com.hilgo.rotax.dto;

import com.hilgo.rotax.enums.DriverStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.validation.constraints.NotNull;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class DriverStatusUpdateRequest {
    @NotNull(message = "Status is required")
    private DriverStatus status;
    
    @NotNull(message = "Location is required")
    private LocationDTO location;
}