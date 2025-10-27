package com.hilgo.rotax.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class DocumentReviewRequest {
    @NotBlank(message = "Reddetme sebebi boş olamaz.")
    private String rejectionReason;
}