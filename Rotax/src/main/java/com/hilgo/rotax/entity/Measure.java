package com.hilgo.rotax.entity;


import com.hilgo.rotax.enums.Size;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class Measure {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column
    private Double weight;

    @Column
    private Double width;

    @Column
    private Double length;

    @Column
    private Double height;

    @Enumerated(EnumType.STRING)
    private Size size;

}