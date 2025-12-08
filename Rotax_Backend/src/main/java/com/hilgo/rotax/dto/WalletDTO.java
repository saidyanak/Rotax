package com.hilgo.rotax.dto;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WalletDTO {
    private Long id;
    private Long userId;
    private String username;
    private BigDecimal balance;
    private BigDecimal frozenBalance;
    private BigDecimal availableBalance;
    private BigDecimal totalEarnings;
    private BigDecimal totalSpent;
    private String currency;
    private Boolean isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
