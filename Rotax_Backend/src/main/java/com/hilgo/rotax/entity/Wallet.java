package com.hilgo.rotax.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "wallet")
public class Wallet {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(nullable = false, precision = 15, scale = 2)
    @Builder.Default
    private BigDecimal balance = BigDecimal.ZERO;

    @Column(nullable = false, precision = 15, scale = 2)
    @Builder.Default
    private BigDecimal frozenBalance = BigDecimal.ZERO; // Bloke tutulan bakiye (devam eden işlemler için)

    @Column(nullable = false, precision = 15, scale = 2)
    @Builder.Default
    private BigDecimal totalEarnings = BigDecimal.ZERO; // Toplam kazanç (sürücüler için)

    @Column(nullable = false, precision = 15, scale = 2)
    @Builder.Default
    private BigDecimal totalSpent = BigDecimal.ZERO; // Toplam harcama (distributorlar için)

    @Column(nullable = false)
    @Builder.Default
    private String currency = "TRY";

    @Column(nullable = false)
    @Builder.Default
    private Boolean isActive = true;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // Kullanılabilir bakiye (toplam - bloke)
    public BigDecimal getAvailableBalance() {
        return balance.subtract(frozenBalance);
    }

    // Bakiye ekleme
    public void addBalance(BigDecimal amount) {
        this.balance = this.balance.add(amount);
    }

    // Bakiye çıkarma
    public void subtractBalance(BigDecimal amount) {
        this.balance = this.balance.subtract(amount);
    }

    // Bakiye bloke etme
    public void freezeBalance(BigDecimal amount) {
        this.frozenBalance = this.frozenBalance.add(amount);
    }

    // Bloke kaldırma
    public void unfreezeBalance(BigDecimal amount) {
        this.frozenBalance = this.frozenBalance.subtract(amount);
    }
}
