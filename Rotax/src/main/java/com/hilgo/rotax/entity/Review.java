package com.hilgo.rotax.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Builder
public class Review {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private int rating; // 1-5 arası puan

    @Lob // Uzun metinler için
    private String comment; // İsteğe bağlı yorum

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private ReviewerType reviewerType; // Yorumu kimin yaptığını belirtir (CUSTOMER, DISTRIBUTOR)

    @Column(updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    // --- İLİŞKİLER ---

    // 1. Cargo ile İlişki: Bire Bir (OneToOne)
    // Her kargonun sadece bir yorumu olabilir.
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cargo_id", nullable = false, unique = true)
    private Cargo cargo;

    // 2. Driver ile İlişki: Çoktan Bire (ManyToOne)
    // Bir sürücünün birden çok yorumu olabilir.
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "driver_id", nullable = false)
    private Driver driver;

    // 3. Distributor ile İlişki: Çoktan Bire (ManyToOne)
    // Bir dağıtıcının (yorum yapan olarak) birden çok yorumu olabilir.
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "distributor_id") // Son kullanıcı yapıyorsa bu alan null olabilir.
    private Distributor distributor;
}
