package com.hilgo.rotax.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WithdrawRequest {
    
    @NotNull(message = "Miktar zorunludur")
    @DecimalMin(value = "10.00", message = "Minimum çekim miktarı 10 TL'dir")
    private BigDecimal amount;

    private String bankAccount; // IBAN (ileride kullanılacak)
    
    private String description;
}
