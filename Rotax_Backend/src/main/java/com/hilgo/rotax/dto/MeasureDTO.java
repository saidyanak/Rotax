package com.hilgo.rotax.dto;

import com.hilgo.rotax.enums.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class MeasureDTO {
    private Double weight;
    private Double width;
    private Double height;
    private Double length;
    private Size size;
}