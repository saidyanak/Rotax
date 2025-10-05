package com.hilgo.rotax.controller;

import com.hilgo.rotax.dto.*;
import com.hilgo.rotax.entity.User;
import com.hilgo.rotax.service.AuthenticationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "Kimlik doğrulama ve kullanıcı kayıt işlemleri")
public class AuthenticationController {

    private final AuthenticationService authenticationService;

    @PostMapping("/register")
    @Operation(summary = "Yeni kullanıcı kaydı", description = "Driver, Distributor veya Pickup Point olarak kayıt olma")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        AuthResponse response = authenticationService.register(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping("/login")
    @Operation(summary = "Kullanıcı girişi", description = "Username veya email ile giriş yapma")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        AuthResponse response = authenticationService.login(request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/me")
    @Operation(summary = "Mevcut kullanıcı bilgisi", description = "Login olan kullanıcının bilgilerini getirir")
    public ResponseEntity<UserDTO> getCurrentUser(@RequestBody Authentication authentication) {
        UserDTO user = authenticationService.getCurrentUser(authentication.getName());
        return ResponseEntity.ok(user);
    }

    @PostMapping("/logout")
    @Operation(summary = "Çıkış yap", description = "Kullanıcı oturumunu sonlandırır")
    public ResponseEntity<String> logout() {
        // Token client-side'da silinecek
        // Backend'de gerekirse token invalidation yapılabilir
        return ResponseEntity.ok("Başarıyla çıkış yapıldı");
    }

    @PostMapping("/forgot-password")
    @Operation(summary = "Şifremi unuttum", description = "Email adresine şifre sıfırlama linki gönderir")
    public ResponseEntity<MessageResponse> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        MessageResponse response = authenticationService.forgotPassword(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/reset-password")
    @Operation(summary = "Şifre sıfırlama", description = "Token ile yeni şifre belirleme")
    public ResponseEntity<MessageResponse> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        MessageResponse response = authenticationService.resetPassword(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/change-password")
    @Operation(summary = "Şifre değiştirme", description = "Mevcut şifre ile yeni şifre belirleme (Login gerekli)")
    public ResponseEntity<MessageResponse> changePassword(
            Authentication authentication,
            @RequestParam String oldPassword,
            @RequestParam String newPassword) {
        MessageResponse response = authenticationService.changePassword(
                authentication.getName(), oldPassword, newPassword);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/validate-reset-token")
    @Operation(summary = "Şifre sıfırlama token doğrulama",
            description = "Frontend'in token'ın geçerliliğini kontrol etmesi için kullanılır")
    public ResponseEntity<ValidateTokenResponse> validateResetToken(@Valid @RequestBody ValidateTokenRequest request) {
        ValidateTokenResponse response = authenticationService.validateResetToken(request);
        return ResponseEntity.ok(response);
    }

    // Alternatif: GET metodu ile de yapılabilir (URL'den token alınır)
    @GetMapping("/validate-reset-token/{token}")
    @Operation(summary = "Şifre sıfırlama token doğrulama (GET)",
            description = "URL parametresi ile token doğrulama")
    public ResponseEntity<ValidateTokenResponse> validateResetTokenByGet(@PathVariable String token) {
        ValidateTokenRequest request = ValidateTokenRequest.builder()
                .token(token)
                .build();
        ValidateTokenResponse response = authenticationService.validateResetToken(request);
        return ResponseEntity.ok(response);
    }
}