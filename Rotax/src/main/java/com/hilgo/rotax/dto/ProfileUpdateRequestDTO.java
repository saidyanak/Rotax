package com.hilgo.rotax.dto;

import com.hilgo.rotax.enums.CarType;

import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProfileUpdateRequestDTO {

    @Size(min = 2, message = "İsim en az 2 karakter olmalıdır")
    private String firstName;

    @Size(min = 2, message = "Soyisim en az 2 karakter olmalıdır")
    private String lastName;

    private String phoneNumber;

    private CarType carType; // Sadece sürücüler için geçerli olacak

    // Sadece dağıtıcılar için geçerli olacak
    private AddressDTO address;
}
