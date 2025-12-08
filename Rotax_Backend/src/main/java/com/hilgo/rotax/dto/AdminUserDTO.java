package com.hilgo.rotax.dto;

import com.hilgo.rotax.enums.Roles;
import lombok.*;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AdminUserDTO {
    private Long id;
    private String username;
    private String email;
    private String firstName;
    private String lastName;
    private String phoneNumber;
    private Roles role;
    private Boolean enabled;
    private Boolean accountNonLocked;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String profilePictureUrl;
    
    // Driver specific
    private String tc;
    private String driverStatus;
    private String carType;
    
    // Distributor specific
    private String vkn;
    
    // İstatistikler
    private Integer totalDocuments;
    private Integer approvedDocuments;
    private Integer pendingDocuments;
}
