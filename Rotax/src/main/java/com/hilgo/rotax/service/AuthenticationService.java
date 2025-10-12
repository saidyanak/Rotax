
package com.hilgo.rotax.service;

import java.time.LocalDateTime;
import java.util.UUID;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.hilgo.rotax.dto.AuthResponse;
import com.hilgo.rotax.dto.ForgotPasswordRequest;
import com.hilgo.rotax.dto.LoginRequest;
import com.hilgo.rotax.dto.MessageResponse;
import com.hilgo.rotax.dto.RegisterRequest;
import com.hilgo.rotax.dto.ResetPasswordRequest;
import com.hilgo.rotax.dto.UserDTO;
import com.hilgo.rotax.dto.ValidateTokenRequest;
import com.hilgo.rotax.dto.ValidateTokenResponse;
import com.hilgo.rotax.entity.Distributor;
import com.hilgo.rotax.entity.Driver;
import com.hilgo.rotax.entity.PasswordResetToken;
import com.hilgo.rotax.entity.User;
import com.hilgo.rotax.entity.UserDocument;
import com.hilgo.rotax.enums.DocumentType;
import com.hilgo.rotax.enums.DriverStatus;
import com.hilgo.rotax.repository.PasswordResetTokenRepository;
import com.hilgo.rotax.repository.UserDocumentRepository;
import com.hilgo.rotax.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthenticationService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final PasswordResetTokenRepository passwordResetTokenRepository;
    private final EmailService emailService;
    private final FileStorageService fileStorageService;
    private final UserDocumentRepository userDocumentRepository;

    @Transactional(readOnly = true)
    public UserDTO getCurrentUser(String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("Kullanıcı bulunamadı: " + username));

        return convertToDTO(user);
    }

    @Transactional
    public MessageResponse forgotPassword(ForgotPasswordRequest request) {
        log.info("Şifre sıfırlama talebi alındı: {}", request.getEmail());

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new UsernameNotFoundException("Bu email adresi ile kayıtlı kullanıcı bulunamadı"));

        // Eski tokenları temizle
        passwordResetTokenRepository.deleteByUser(user);

        // Yeni token oluştur
        String token = UUID.randomUUID().toString();
        PasswordResetToken resetToken = PasswordResetToken.builder()
                .token(token)
                .user(user)
                .expiryDate(LocalDateTime.now().plusHours(1)) // 1 saat geçerli
                .used(false)
                .build();

        passwordResetTokenRepository.save(resetToken);

        // Email gönderme işlemi
        emailService.sendPasswordResetEmail(user.getEmail(), user.getFirstName(), token);

        // Geliştirme ortamında token'ı loglayalım (Production'da kaldırılmalı!)
        log.warn("DEVELOPMENT - Reset Token: {}", token);

        return MessageResponse.builder()
                .message("Şifre sıfırlama linki email adresinize gönderildi")
                .success(true)
                .build();
    }

    @Transactional
    public MessageResponse resetPassword(ResetPasswordRequest request) {
        log.info("Şifre sıfırlama işlemi başlatıldı");

        // Şifre ve şifre tekrarı kontrolü
        if (!request.getNewPassword().equals(request.getConfirmPassword())) {
            throw new IllegalArgumentException("Şifreler eşleşmiyor");
        }

        // Token kontrolü
        PasswordResetToken resetToken = passwordResetTokenRepository.findByToken(request.getToken())
                .orElseThrow(() -> new IllegalArgumentException("Geçersiz token"));

        // Token kullanılmış mı?
        if (resetToken.getUsed()) {
            throw new IllegalArgumentException("Bu token daha önce kullanılmış");
        }

        // Token süresi dolmuş mu?
        if (resetToken.isExpired()) {
            throw new IllegalArgumentException("Token süresi dolmuş. Lütfen yeni bir şifre sıfırlama talebi oluşturun");
        }

        // Şifreyi güncelle
        User user = resetToken.getUser();
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);

        // Token'ı kullanılmış olarak işaretle
        resetToken.setUsed(true);
        passwordResetTokenRepository.save(resetToken);

        log.info("Şifre başarıyla sıfırlandı: {}", user.getUsername());

        return MessageResponse.builder()
                .message("Şifreniz başarıyla sıfırlandı. Yeni şifreniz ile giriş yapabilirsiniz")
                .success(true)
                .build();
    }

    @Transactional
    public MessageResponse changePassword(String username, String oldPassword, String newPassword) {
        log.info("Şifre değiştirme işlemi başlatıldı: {}", username);

        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("Kullanıcı bulunamadı"));

        // Eski şifre kontrolü
        if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
            throw new IllegalArgumentException("Mevcut şifre hatalı");
        }

        // Yeni şifreyi kaydet
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);

        log.info("Şifre başarıyla değiştirildi: {}", username);

        return MessageResponse.builder()
                .message("Şifreniz başarıyla değiştirildi")
                .success(true)
                .build();
    }

    public UserDTO convertToDTO(User user) {
        return UserDTO.builder()
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .phoneNumber(user.getPhoneNumber())
                .role(user.getRole())
                .enabled(user.getEnabled())
                .createdAt(user.getCreatedAt())
                .profilePictureUrl(user.getProfilePictureUrl())
                .build();
    }

    @Transactional
    public AuthResponse register(RegisterRequest request, MultipartFile[] documents) {
        log.info("Yeni kullanıcı kaydı başlatıldı: {} - Role: {}", request.getUsername(), request.getRoles());

        // Kullanıcı adı kontrolü
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new IllegalArgumentException("Bu kullanıcı adı zaten kullanılıyor");
        }

        // Email kontrolü
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Bu email adresi zaten kullanılıyor");
        }

        User newUser;
        switch (request.getRoles()) {
            case DRIVER:
                Driver driver = new Driver();
                driver.setTc(request.getTc());
                driver.setDriverStatus(DriverStatus.OFFLINE);
                driver.setCarType(request.getCarType());
                newUser = driver;
                break;
            case DISTRIBUTOR:
                Distributor distributor = new Distributor();
                distributor.setVkn(request.getVkn());
                newUser = distributor;
                break;
            default:
                // Diğer roller veya varsayılan durum için sadece User oluşturulabilir
                // veya hata fırlatılabilir.
                throw new IllegalArgumentException("Desteklenmeyen kullanıcı rolü: " + request.getRoles());
        }

        // Ortak alanları ata
        newUser.setUsername(request.getUsername());
        newUser.setEmail(request.getEmail());
        newUser.setPassword(passwordEncoder.encode(request.getPassword()));
        newUser.setFirstName(request.getFirstName());
        newUser.setLastName(request.getLastName());
        newUser.setPhoneNumber(request.getPhoneNumber());
        newUser.setRole(request.getRoles());
        newUser.setEnabled(false); // Belgeler onaylanana kadar hesap pasif kalacak
        newUser.setAccountNonExpired(true);
        newUser.setAccountNonLocked(true);
        newUser.setCredentialsNonExpired(true);

        User savedUser = userRepository.save(newUser);
        log.info("Kullanıcı başarıyla kaydedildi: {}", savedUser.getUsername());

        // Belgeleri işle (eğer varsa)
        if (documents != null && documents.length > 0) {
            log.info("{} adet belge yükleniyor...", documents.length);
            for (MultipartFile docFile : documents) {
                String fileUrl = fileStorageService.storeFile(docFile);
                // Dosya adından belge tipini çıkarmaya çalışalım (örn: "ehliyet.pdf")
                String originalFilename = docFile.getOriginalFilename().toUpperCase();
                DocumentType docType = determineDocumentType(originalFilename);

                UserDocument userDocument = UserDocument.builder()
                        .user(savedUser)
                        .documentType(docType)
                        .fileUrl(fileUrl)
                        .build();
                userDocumentRepository.save(userDocument);
            }
        }

        // JWT token oluştur
        String jwtToken = jwtService.generateToken(savedUser);

        // Hoş geldin e-postası gönder
        emailService.sendRegistrationConfirmationEmail(savedUser.getEmail(), savedUser.getFirstName());

        return AuthResponse.builder()
                .token(jwtToken)
                .type("Bearer")
                .id(savedUser.getId())
                .username(savedUser.getUsername())
                .email(savedUser.getEmail())
                .firstName(savedUser.getFirstName())
                .lastName(savedUser.getLastName())
                .role(savedUser.getRole())
                .build();
    }

    private DocumentType determineDocumentType(String filename) {
        if (filename == null) return DocumentType.IDENTITY_CARD; // Varsayılan
        if (filename.contains("EHLIYET") || filename.contains("LICENSE")) {
            return DocumentType.DRIVERS_LICENSE;
        }
        if (filename.contains("RUHSAT") || filename.contains("REGISTRATION")) {
            return DocumentType.VEHICLE_REGISTRATION;
        }
        if (filename.contains("ADLI") || filename.contains("CRIMINAL")) {
            return DocumentType.CRIMINAL_RECORD;
        }
        return DocumentType.IDENTITY_CARD;
    }

    @Transactional(readOnly = true)
    public AuthResponse login(LoginRequest request) {
        log.info("Login denemesi: {}", request.getUsernameOrEmail());

        // Kullanıcıyı bul (username veya email ile)
        User user = userRepository.findByUsername(request.getUsernameOrEmail())
                .orElseThrow(() -> new UsernameNotFoundException("Kullanıcı bulunamadı"));

        // Authentication işlemi
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        user.getUsername(),
                        request.getPassword()
                )
        );

        log.info("Login oldum {} - Role: {}", user.getUsername(), user.getRole());

        // JWT token oluştur
        String jwtToken = jwtService.generateToken(user);

        return AuthResponse.builder()
                .token(jwtToken)
                .type("Bearer")
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .role(user.getRole())
                .build();
    }

    @Transactional(readOnly = true)
    public ValidateTokenResponse validateResetToken(ValidateTokenRequest request) {
        log.info("Token doğrulama isteği alındı");

        try {
            // Token kontrolü
            PasswordResetToken resetToken = passwordResetTokenRepository.findByToken(request.getToken())
                    .orElseThrow(() -> new IllegalArgumentException("Geçersiz token"));

            // Token kullanılmış mı?
            if (resetToken.getUsed()) {
                return ValidateTokenResponse.builder()
                        .valid(false)
                        .message("Bu token daha önce kullanılmış")
                        .build();
            }

            // Token süresi dolmuş mu?
            if (resetToken.isExpired()) {
                return ValidateTokenResponse.builder()
                        .valid(false)
                        .message("Token süresi dolmuş. Lütfen yeni bir şifre sıfırlama talebi oluşturun")
                        .build();
            }

            // Token geçerli
            log.info("Token geçerli: {}", resetToken.getUser().getEmail());
            return ValidateTokenResponse.builder()
                    .valid(true)
                    .message("Token geçerli")
                    .email(resetToken.getUser().getEmail())
                    .build();

        } catch (IllegalArgumentException e) {
            log.warn("Geçersiz token doğrulama denemesi");
            return ValidateTokenResponse.builder()
                    .valid(false)
                    .message("Geçersiz veya bulunamayan token")
                    .build();
        }
    }
}