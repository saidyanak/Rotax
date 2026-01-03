package com.hilgo.rotax.entity;

import java.util.List;

import com.hilgo.rotax.enums.CarType;
import com.hilgo.rotax.enums.DriverStatus;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class Driver extends User{

    @Column
    private String tc;

    @OneToOne(cascade = CascadeType.ALL)
    @JoinColumn(name = "location_id")
    private Location location;
    
    // Sürücünün hedef lokasyonu (DESTINATION_BASED modu için)
    @OneToOne(cascade = CascadeType.ALL)
    @JoinColumn(name = "destination_id")
    private Location destination;
    
    // Rota üzerinde kabul edilecek maksimum sapma mesafesi (km)
    @Column
    private Double maxDeviationKm = 5.0;

    @Enumerated(EnumType.STRING)
    private DriverStatus driverStatus =  DriverStatus.OFFLINE;

    @Enumerated(EnumType.STRING)
    private CarType carType;

    @OneToMany(mappedBy = "driver")
    private List<Cargo> cargos;
}
