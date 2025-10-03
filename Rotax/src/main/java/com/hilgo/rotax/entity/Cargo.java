package com.hilgo.rotax.entity;

import com.hilgo.rotax.enums.CargoSituation;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Builder
public class Cargo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private String id;

    @OneToOne
    private Location selfLocation;

    @OneToOne
    private Location targetLocation;

    @OneToOne
    private Measure measure;

    @Enumerated(EnumType.STRING)
    private CargoSituation cargoSituation;

    @Column
    private String phoneNumber;

    @Column
    private String verificationCode;

    @Column
    private String description;

    @Column
    private LocalDateTime takingTime;

    @Column
    private LocalDateTime deliveredTime;

    @ManyToOne
    @JoinColumn(name = "distributor_user_id", referencedColumnName = "user_id")
    private Distributor distributor;

    @ManyToOne
    @JoinColumn(name = "driver_user_id", referencedColumnName = "user_id")
    private Driver driver;

    @CreationTimestamp
    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
