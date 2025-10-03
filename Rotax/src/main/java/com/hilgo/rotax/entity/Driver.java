package com.hilgo.rotax.entity;

import com.hilgo.rotax.enums.CarType;
import com.hilgo.rotax.enums.DriverStatus;
import jakarta.persistence.*;
import lombok.*;

import java.util.List;

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
