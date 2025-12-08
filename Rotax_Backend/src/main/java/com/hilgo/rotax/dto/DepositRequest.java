package com.hilgo.rotax.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DepositRequest {
    
    @NotNull(message = "Miktar zorunludur")
    @DecimalMin(value = "1.00", message = "Minimum yükleme miktarı 1 TL'dir")
    private BigDecimal amount;

    private String paymentMethod; // Ödeme yöntemi (ileride kullanılacak)
    
    private String description;
}
