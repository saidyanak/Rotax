package com.hilgo.rotax.entity;

import java.util.List;

import com.hilgo.rotax.enums.CarType;
import com.hilgo.rotax.enums.DriverStatus;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
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

    @OneToOne
    private Location location;

    @Enumerated(EnumType.STRING)
    private DriverStatus driverStatus =  DriverStatus.OFFLINE;

    @Enumerated(EnumType.STRING)
    private CarType carType;

    @OneToMany(mappedBy = "driver")
    private List<Cargo> cargos;
}
