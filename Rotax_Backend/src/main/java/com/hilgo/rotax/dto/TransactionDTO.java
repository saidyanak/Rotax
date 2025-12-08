package com.hilgo.rotax.dto;

import com.hilgo.rotax.enums.TransactionStatus;
import com.hilgo.rotax.enums.TransactionType;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransactionDTO {
    private Long id;
    private String transactionReference;
    private TransactionType transactionType;
    private TransactionStatus status;
    private BigDecimal amount;
    private BigDecimal fee;
    private BigDecimal balanceBefore;
    private BigDecimal balanceAfter;
    private String currency;
    private String description;
    private Long cargoId;
    private String paymentMethod;
    private LocalDateTime createdAt;
    private LocalDateTime completedAt;
}
