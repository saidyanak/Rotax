package com.hilgo.rotax.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.validation.constraints.NotBlank;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class DeliveryNoteRequest {
    @NotBlank(message = "Delivery note is required")
    private String note;
}