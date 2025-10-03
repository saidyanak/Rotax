package com.hilgo.rotax.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LoginRequest {

    @NotBlank(message = "Kullanıcı adı veya email boş olamaz")
    private String usernameOrEmail;

    @NotBlank(message = "Şifre boş olamaz")
    private String password;
}