package com.hilgo.rotax.dto;

import com.hilgo.rotax.enums.Roles;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserDTO {
    private Long id;
    private String username;
    private String email;
    private String firstName;
    private String lastName;
    private String phoneNumber;
    private Roles role;
    private Boolean enabled;
    private LocalDateTime createdAt;
    private String profilePictureUrl;
}
