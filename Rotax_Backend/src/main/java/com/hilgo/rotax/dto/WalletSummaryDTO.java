package com.hilgo.rotax.dto;

import lombok.*;

import java.math.BigDecimal;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WalletSummaryDTO {
    private WalletDTO wallet;
    private BigDecimal totalDeposits;      // Toplam yüklenen
    private BigDecimal totalWithdrawals;   // Toplam çekilen
    private BigDecimal pendingAmount;      // Bekleyen işlemler
    private Integer totalTransactions;     // Toplam işlem sayısı
    private List<TransactionDTO> recentTransactions; // Son işlemler
}
