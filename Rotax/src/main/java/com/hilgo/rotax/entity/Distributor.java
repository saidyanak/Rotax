package com.hilgo.rotax.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
import lombok.*;

import java.util.List;

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
