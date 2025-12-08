package com.hilgo.rotax.config; // veya uygun package'ınız

import com.hilgo.rotax.entity.Driver;
import com.hilgo.rotax.entity.Distributor;
import com.hilgo.rotax.entity.User;
import com.hilgo.rotax.enums.CarType;
import com.hilgo.rotax.enums.DriverStatus;
import com.hilgo.rotax.enums.Roles;
import com.hilgo.rotax.repository.DriverRepository;
import com.hilgo.rotax.repository.DistributorRepository;
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
    private final DriverRepository driverRepository;
    private final DistributorRepository distributorRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        createAdminUser();
        createTestDriver();
        createTestDistributor();
    }
    
    private void createAdminUser() {
        try {
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
                System.out.println("✅ Admin kullanıcı oluşturuldu: admin / admin123");
            } else {
                System.out.println("ℹ️ Admin kullanıcı zaten mevcut");
            }
        } catch (Exception e) {
            System.err.println("❌ Admin oluşturma hatası: " + e.getMessage());
        }
    }
    
    private void createTestDriver() {
        try {
            if (!userRepository.existsByEmail("driver@rotax.com")) {
                Driver driver = new Driver();
                driver.setUsername("driver");
                driver.setEmail("driver@rotax.com");
                driver.setPassword(passwordEncoder.encode("driver123"));
                driver.setFirstName("Test");
                driver.setLastName("Sürücü");
                driver.setPhoneNumber("+905559876543");
                driver.setRole(Roles.DRIVER);
                driver.setEnabled(true); // Test kullanıcısı için aktif
                driver.setAccountNonExpired(true);
                driver.setAccountNonLocked(true);
                driver.setCredentialsNonExpired(true);
                driver.setCreatedAt(LocalDateTime.now());
                driver.setUpdatedAt(LocalDateTime.now());
                driver.setTc("12345678901");
                driver.setCarType(CarType.SEDAN);
                driver.setDriverStatus(DriverStatus.OFFLINE);

                driverRepository.save(driver);
                System.out.println("✅ Test sürücü oluşturuldu: driver / driver123");
            } else {
                System.out.println("ℹ️ Test sürücü zaten mevcut");
            }
        } catch (Exception e) {
            System.err.println("❌ Test sürücü oluşturma hatası: " + e.getMessage());
        }
    }
    
    private void createTestDistributor() {
        try {
            if (!userRepository.existsByEmail("distributor@rotax.com")) {
                Distributor distributor = new Distributor();
                distributor.setUsername("distributor");
                distributor.setEmail("distributor@rotax.com");
                distributor.setPassword(passwordEncoder.encode("distributor123"));
                distributor.setFirstName("Test");
                distributor.setLastName("Dağıtıcı");
                distributor.setPhoneNumber("+905551112233");
                distributor.setRole(Roles.DISTRIBUTOR);
                distributor.setEnabled(true); // Test kullanıcısı için aktif
                distributor.setAccountNonExpired(true);
                distributor.setAccountNonLocked(true);
                distributor.setCredentialsNonExpired(true);
                distributor.setCreatedAt(LocalDateTime.now());
                distributor.setUpdatedAt(LocalDateTime.now());
                distributor.setVkn("1234567890");

                distributorRepository.save(distributor);
                System.out.println("✅ Test dağıtıcı oluşturuldu: distributor / distributor123");
            } else {
                System.out.println("ℹ️ Test dağıtıcı zaten mevcut");
            }
        } catch (Exception e) {
            System.err.println("❌ Test dağıtıcı oluşturma hatası: " + e.getMessage());
        }
    }
}