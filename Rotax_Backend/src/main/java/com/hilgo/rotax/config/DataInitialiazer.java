package com.hilgo.rotax.config; // veya uygun package'ınız

import com.hilgo.rotax.entity.User;
import com.hilgo.rotax.enums.Roles;
import com.hilgo.rotax.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
@RequiredArgsConstructor
public class DataInitialiazer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        try {
            // Admin kullanıcı zaten var mı kontrol et
            if (!userRepository.existsByEmail("admin@rotax.com")) {
                User admin = User.builder()
                        .username("admin")
                        .email("admin@rotax.com")
                        .password(passwordEncoder.encode("admin123"))
                        .firstName("Admin")
                        .lastName("User")
                        .phoneNumber("+905551234567")
                        .role(Roles.ADMIN)
                        .enabled(true)
                        .accountNonExpired(true)
                        .accountNonLocked(true)
                        .credentialsNonExpired(true)
                        .createdAt(LocalDateTime.now())
                        .updatedAt(LocalDateTime.now())
                        .build();

                userRepository.save(admin);
                System.out.println("✅ Admin kullanıcı oluşturuldu: admin@rotax.com");
                System.out.println("📧 Email: admin@rotax.com");
                System.out.println("🔑 Şifre: admin123");
            } else {
                System.out.println("ℹ️ Admin kullanıcı zaten mevcut");
            }
        } catch (Exception e) {
            System.err.println("❌ Admin oluşturma hatası: " + e.getMessage());
            e.printStackTrace();
        }
    }
}