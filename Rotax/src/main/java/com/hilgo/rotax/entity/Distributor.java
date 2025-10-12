package com.hilgo.rotax.entity;

import java.util.List;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@EqualsAndHashCode(callSuper = true)
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class Distributor extends User{


    @Column
    private String vkn;

    @OneToOne
    private Address address;

    @OneToMany(mappedBy = "distributor")
    private List<Cargo> cargo;
}
