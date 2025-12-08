package com.hilgo.rotax.service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.hilgo.rotax.dto.*;
import com.hilgo.rotax.entity.*;
import com.hilgo.rotax.enums.*;
import com.hilgo.rotax.exception.ResourceNotFoundException;
import com.hilgo.rotax.repository.*;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class AdminService {

    private final UserDocumentRepository userDocumentRepository;
    private final UserRepository userRepository;
    private final DriverRepository driverRepository;
    private final DistributorRepository distributorRepository;
    private final CargoRepository cargoRepository;
    private final TransactionRepository transactionRepository;
    private final EmailService emailService;

    // =============== DASHBOARD ===============

    /**
     * Admin dashboard istatistikleri
     */
    @Transactional(readOnly = true)
    public AdminDashboardDTO getDashboard() {
        // Kullanıcı istatistikleri
        long totalUsers = userRepository.count();
        long totalDrivers = driverRepository.count();
        long totalDistributors = distributorRepository.count();
        long activeDrivers = driverRepository.countByDriverStatus(DriverStatus.ACTIVE);
        long pendingVerifications = userDocumentRepository.countByVerificationStatus(VerificationStatus.PENDING);

        // Kargo istatistikleri
        long totalCargos = cargoRepository.count();
        long activeCargos = cargoRepository.countByCargoSituationIn(
                List.of(CargoSituation.CREATED, CargoSituation.ASSIGNED, CargoSituation.PICKED_UP));
        long deliveredCargos = cargoRepository.countByCargoSituation(CargoSituation.DELIVERED);
        long cancelledCargos = cargoRepository.countByCargoSituation(CargoSituation.CANCELLED);

        // Finansal istatistikler (basit toplam)
        BigDecimal totalRevenue = transactionRepository.getTotalCommissions();
        BigDecimal pendingWithdrawals = transactionRepository.getTotalPendingWithdrawals();

        // Son 7 gün için günlük kargo ve kullanıcı sayıları
        Map<String, Long> cargosPerDay = new LinkedHashMap<>();
        Map<String, Long> newUsersPerDay = new LinkedHashMap<>();

        LocalDate today = LocalDate.now();
        for (int i = 6; i >= 0; i--) {
            LocalDate date = today.minusDays(i);
            String dateStr = date.toString();
            cargosPerDay.put(dateStr, cargoRepository.countByCreatedAtDate(date));
            newUsersPerDay.put(dateStr, userRepository.countByCreatedAtDate(date));
        }

        return AdminDashboardDTO.builder()
                .totalUsers(totalUsers)
                .totalDrivers(totalDrivers)
                .totalDistributors(totalDistributors)
                .activeDrivers(activeDrivers)
                .pendingVerifications(pendingVerifications)
                .totalCargos(totalCargos)
                .activeCargos(activeCargos)
                .deliveredCargos(deliveredCargos)
                .cancelledCargos(cancelledCargos)
                .totalRevenue(totalRevenue != null ? totalRevenue : BigDecimal.ZERO)
                .pendingWithdrawals(pendingWithdrawals != null ? pendingWithdrawals : BigDecimal.ZERO)
                .cargosPerDay(cargosPerDay)
                .newUsersPerDay(newUsersPerDay)
                .build();
    }

    // =============== USER MANAGEMENT ===============

    /**
     * Tüm kullanıcıları listeler
     */
    @Transactional(readOnly = true)
    public Page<AdminUserDTO> getAllUsers(Pageable pageable, Roles roleFilter) {
        Page<User> users;
        if (roleFilter != null) {
            users = userRepository.findByRole(roleFilter, pageable);
        } else {
            users = userRepository.findAll(pageable);
        }
        return users.map(this::convertToAdminUserDTO);
    }

    /**
     * Kullanıcı detayı
     */
    @Transactional(readOnly = true)
    public AdminUserDTO getUserById(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));
        return convertToAdminUserDTO(user);
    }

    /**
     * Kullanıcı aktif/pasif durumunu değiştirir
     */
    @Transactional
    public AdminUserDTO toggleUserStatus(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));
        
        user.setEnabled(!user.getEnabled());
        user = userRepository.save(user);
        
        log.info("Kullanıcı durumu değiştirildi: {} -> {}", user.getUsername(), user.getEnabled() ? "Aktif" : "Pasif");
        return convertToAdminUserDTO(user);
    }

    /**
     * Kullanıcı hesabını kilitler/açar
     */
    @Transactional
    public AdminUserDTO toggleUserLock(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));
        
        user.setAccountNonLocked(!user.getAccountNonLocked());
        user = userRepository.save(user);
        
        log.info("Kullanıcı kilidi değiştirildi: {} -> {}", user.getUsername(), user.getAccountNonLocked() ? "Açık" : "Kilitli");
        return convertToAdminUserDTO(user);
    }

    // =============== CARGO MANAGEMENT ===============

    /**
     * Tüm kargoları listeler
     */
    @Transactional(readOnly = true)
    public Page<AdminCargoDTO> getAllCargos(Pageable pageable, CargoSituation statusFilter) {
        Page<Cargo> cargos;
        if (statusFilter != null) {
            cargos = cargoRepository.findByCargoSituation(statusFilter, pageable);
        } else {
            cargos = cargoRepository.findAll(pageable);
        }
        return cargos.map(this::convertToAdminCargoDTO);
    }

    /**
     * Kargo detayı
     */
    @Transactional(readOnly = true)
    public AdminCargoDTO getCargoById(Long cargoId) {
        Cargo cargo = cargoRepository.findById(cargoId)
                .orElseThrow(() -> new ResourceNotFoundException("Cargo", "id", cargoId));
        return convertToAdminCargoDTO(cargo);
    }

    /**
     * Kargoyu iptal eder (Admin yetkisiyle)
     */
    @Transactional
    public AdminCargoDTO cancelCargo(Long cargoId, String reason) {
        Cargo cargo = cargoRepository.findById(cargoId)
                .orElseThrow(() -> new ResourceNotFoundException("Cargo", "id", cargoId));
        
        cargo.setCargoSituation(CargoSituation.CANCELLED);
        cargo.setDescription(cargo.getDescription() + " | Admin tarafından iptal: " + reason);
        cargo = cargoRepository.save(cargo);
        
        log.warn("Kargo admin tarafından iptal edildi: ID {}, Sebep: {}", cargoId, reason);
        return convertToAdminCargoDTO(cargo);
    }

    // =============== DOCUMENT MANAGEMENT ===============

    /**
     * Onay bekleyen tüm belgeleri listeler.
     */
    @Transactional(readOnly = true)
    public List<UserDocumentDTO> getPendingDocuments() {
        return userDocumentRepository.findByVerificationStatus(VerificationStatus.PENDING)
                .stream()
                .map(this::convertToDocumentDTO)
                .collect(Collectors.toList());
    }

    /**
     * Bir belgeyi onaylar.
     */
    @Transactional
    public UserDocumentDTO approveDocument(Long documentId) {
        UserDocument document = userDocumentRepository.findById(documentId)
                .orElseThrow(() -> new ResourceNotFoundException("UserDocument", "id", documentId));

        document.setVerificationStatus(VerificationStatus.APPROVED);
        document.setVerifiedAt(LocalDateTime.now());
        document.setRejectionReason(null);

        UserDocument savedDocument = userDocumentRepository.save(document);
        log.info("Belge ID {} onaylandı. Kullanıcı: {}", documentId, savedDocument.getUser().getUsername());

        checkAndActivateUser(savedDocument.getUser());

        return convertToDocumentDTO(savedDocument);
    }

    private void checkAndActivateUser(User user) {
        if (user.getRole() == Roles.DRIVER) {
            List<UserDocument> documents = user.getDocuments();

            if (documents.isEmpty() || documents.stream().anyMatch(doc -> doc.getVerificationStatus() != VerificationStatus.APPROVED)) {
                return;
            }

            if (!user.getEnabled()) {
                user.setEnabled(true);
                userRepository.save(user);
                log.info("Tüm belgeler onaylandı. Kullanıcı hesabı aktive edildi: {}", user.getUsername());
            }
        }
    }

    /**
     * Bir belgeyi reddeder.
     */
    @Transactional
    public UserDocumentDTO rejectDocument(Long documentId, DocumentReviewRequest request) {
        UserDocument document = userDocumentRepository.findById(documentId)
                .orElseThrow(() -> new ResourceNotFoundException("UserDocument", "id", documentId));

        document.setVerificationStatus(VerificationStatus.REJECTED);
        document.setVerifiedAt(LocalDateTime.now());
        document.setRejectionReason(request.getRejectionReason());

        UserDocument savedDocument = userDocumentRepository.save(document);
        log.warn("Belge ID {} reddedildi. Sebep: {}", documentId, request.getRejectionReason());

        User user = savedDocument.getUser();
        emailService.sendDocumentRejectionEmail(
                user.getEmail(),
                user.getFirstName(),
                savedDocument.getDocumentType().toString(),
                request.getRejectionReason());

        return convertToDocumentDTO(savedDocument);
    }

    // =============== TRANSACTION MANAGEMENT ===============

    /**
     * Bekleyen çekim taleplerini listeler
     */
    @Transactional(readOnly = true)
    public Page<TransactionDTO> getPendingWithdrawals(Pageable pageable) {
        return transactionRepository.findByStatusOrderByCreatedAtDesc(TransactionStatus.PENDING, pageable)
                .map(this::convertToTransactionDTO);
    }

    /**
     * Çekim talebini onaylar
     */
    @Transactional
    public TransactionDTO approveWithdrawal(Long transactionId) {
        Transaction transaction = transactionRepository.findById(transactionId)
                .orElseThrow(() -> new ResourceNotFoundException("Transaction", "id", transactionId));
        
        if (transaction.getTransactionType() != TransactionType.WITHDRAWAL) {
            throw new IllegalArgumentException("Bu işlem bir çekim talebi değil");
        }
        
        transaction.complete();
        transaction = transactionRepository.save(transaction);
        
        log.info("Çekim talebi onaylandı: ID {}, Miktar: {}", transactionId, transaction.getAmount());
        return convertToTransactionDTO(transaction);
    }

    /**
     * Çekim talebini reddeder
     */
    @Transactional
    public TransactionDTO rejectWithdrawal(Long transactionId, String reason) {
        Transaction transaction = transactionRepository.findById(transactionId)
                .orElseThrow(() -> new ResourceNotFoundException("Transaction", "id", transactionId));
        
        if (transaction.getTransactionType() != TransactionType.WITHDRAWAL) {
            throw new IllegalArgumentException("Bu işlem bir çekim talebi değil");
        }
        
        // Bakiyeyi geri iade et
        Wallet wallet = transaction.getWallet();
        wallet.addBalance(transaction.getAmount());
        
        transaction.cancel();
        transaction.setDescription(transaction.getDescription() + " | Reddedildi: " + reason);
        transaction = transactionRepository.save(transaction);
        
        log.warn("Çekim talebi reddedildi: ID {}, Sebep: {}", transactionId, reason);
        return convertToTransactionDTO(transaction);
    }

    // =============== CONVERTER METHODS ===============

    private AdminUserDTO convertToAdminUserDTO(User user) {
        AdminUserDTO.AdminUserDTOBuilder builder = AdminUserDTO.builder()
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .phoneNumber(user.getPhoneNumber())
                .role(user.getRole())
                .enabled(user.getEnabled())
                .accountNonLocked(user.getAccountNonLocked())
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .profilePictureUrl(user.getProfilePictureUrl());

        // Belge istatistikleri
        List<UserDocument> documents = user.getDocuments();
        builder.totalDocuments(documents.size());
        builder.approvedDocuments((int) documents.stream()
                .filter(d -> d.getVerificationStatus() == VerificationStatus.APPROVED).count());
        builder.pendingDocuments((int) documents.stream()
                .filter(d -> d.getVerificationStatus() == VerificationStatus.PENDING).count());

        // Driver specific
        if (user instanceof Driver driver) {
            builder.tc(driver.getTc());
            builder.driverStatus(driver.getDriverStatus() != null ? driver.getDriverStatus().name() : null);
            builder.carType(driver.getCarType() != null ? driver.getCarType().name() : null);
        }

        // Distributor specific
        if (user instanceof Distributor distributor) {
            builder.vkn(distributor.getVkn());
        }

        return builder.build();
    }

    private AdminCargoDTO convertToAdminCargoDTO(Cargo cargo) {
        return AdminCargoDTO.builder()
                .id(cargo.getId())
                .trackingCode(cargo.getVerificationCode())
                .cargoSituation(cargo.getCargoSituation())
                .pickupAddress(cargo.getSelfLocation() != null ? cargo.getSelfLocation().getAddress() : null)
                .pickupCity(cargo.getSelfLocation() != null ? cargo.getSelfLocation().getCity() : null)
                .deliveryAddress(cargo.getTargetLocation() != null ? cargo.getTargetLocation().getAddress() : null)
                .deliveryCity(cargo.getTargetLocation() != null ? cargo.getTargetLocation().getCity() : null)
                .distributorId(cargo.getDistributor() != null ? cargo.getDistributor().getId() : null)
                .distributorName(cargo.getDistributor() != null ? 
                        cargo.getDistributor().getFirstName() + " " + cargo.getDistributor().getLastName() : null)
                .distributorEmail(cargo.getDistributor() != null ? cargo.getDistributor().getEmail() : null)
                .driverId(cargo.getDriver() != null ? cargo.getDriver().getId() : null)
                .driverName(cargo.getDriver() != null ? 
                        cargo.getDriver().getFirstName() + " " + cargo.getDriver().getLastName() : null)
                .driverPhone(cargo.getDriver() != null ? cargo.getDriver().getPhoneNumber() : null)
                .recipientPhone(cargo.getPhoneNumber())
                .createdAt(cargo.getCreatedAt())
                .takingTime(cargo.getTakingTime())
                .deliveredTime(cargo.getDeliveredTime())
                .weight(cargo.getMeasure() != null ? cargo.getMeasure().getWeight() : null)
                .size(cargo.getMeasure() != null && cargo.getMeasure().getSize() != null ? 
                        cargo.getMeasure().getSize().name() : null)
                .build();
    }

    private UserDocumentDTO convertToDocumentDTO(UserDocument document) {
        User user = document.getUser();
        return UserDocumentDTO.builder()
                .id(document.getId())
                .userId(user.getId())
                .username(user.getUsername())
                .documentType(document.getDocumentType())
                .fileUrl(document.getFileUrl())
                .verificationStatus(document.getVerificationStatus())
                .rejectionReason(document.getRejectionReason())
                .uploadedAt(document.getUploadedAt())
                .build();
    }

    private TransactionDTO convertToTransactionDTO(Transaction transaction) {
        return TransactionDTO.builder()
                .id(transaction.getId())
                .transactionReference(transaction.getTransactionReference())
                .transactionType(transaction.getTransactionType())
                .status(transaction.getStatus())
                .amount(transaction.getAmount())
                .fee(transaction.getFee())
                .balanceBefore(transaction.getBalanceBefore())
                .balanceAfter(transaction.getBalanceAfter())
                .currency(transaction.getCurrency())
                .description(transaction.getDescription())
                .cargoId(transaction.getCargo() != null ? transaction.getCargo().getId() : null)
                .paymentMethod(transaction.getPaymentMethod())
                .createdAt(transaction.getCreatedAt())
                .completedAt(transaction.getCompletedAt())
                .build();
    }
}