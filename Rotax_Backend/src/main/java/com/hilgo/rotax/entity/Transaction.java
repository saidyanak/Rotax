package com.hilgo.rotax.entity;

import com.hilgo.rotax.enums.TransactionStatus;
import com.hilgo.rotax.enums.TransactionType;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "transaction", indexes = {
    @Index(name = "idx_transaction_wallet", columnList = "wallet_id"),
    @Index(name = "idx_transaction_cargo", columnList = "cargo_id"),
    @Index(name = "idx_transaction_type", columnList = "transaction_type"),
    @Index(name = "idx_transaction_created", columnList = "created_at")
})
public class Transaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "wallet_id", nullable = false)
    private Wallet wallet;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cargo_id")
    private Cargo cargo; // İlgili kargo (varsa)

    @Column(nullable = false, unique = true)
    private String transactionReference; // Benzersiz işlem referansı

    @Enumerated(EnumType.STRING)
    @Column(name = "transaction_type", nullable = false)
    private TransactionType transactionType;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private TransactionStatus status = TransactionStatus.PENDING;

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal amount;

    @Column(precision = 15, scale = 2)
    @Builder.Default
    private BigDecimal fee = BigDecimal.ZERO; // İşlem ücreti/komisyon

    @Column(precision = 15, scale = 2)
    private BigDecimal balanceBefore; // İşlem öncesi bakiye

    @Column(precision = 15, scale = 2)
    private BigDecimal balanceAfter; // İşlem sonrası bakiye

    @Column(nullable = false)
    @Builder.Default
    private String currency = "TRY";

    @Column
    private String description;

    @Column
    private String externalReference; // Harici ödeme sistemi referansı (ileride)

    @Column
    private String paymentMethod; // Ödeme yöntemi (kredi kartı, banka transferi vs.)

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    // İşlemi tamamla
    public void complete() {
        this.status = TransactionStatus.COMPLETED;
        this.completedAt = LocalDateTime.now();
    }

    // İşlemi başarısız yap
    public void fail() {
        this.status = TransactionStatus.FAILED;
    }

    // İşlemi iptal et
    public void cancel() {
        this.status = TransactionStatus.CANCELLED;
    }
}
