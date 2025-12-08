package com.hilgo.rotax.service;

import com.hilgo.rotax.dto.*;
import com.hilgo.rotax.entity.*;
import com.hilgo.rotax.enums.TransactionStatus;
import com.hilgo.rotax.enums.TransactionType;
import com.hilgo.rotax.exception.BadRequestException;
import com.hilgo.rotax.exception.ResourceNotFoundException;
import com.hilgo.rotax.repository.TransactionRepository;
import com.hilgo.rotax.repository.UserRepository;
import com.hilgo.rotax.repository.WalletRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class WalletService {

    private final WalletRepository walletRepository;
    private final TransactionRepository transactionRepository;
    private final UserRepository userRepository;

    // Sistem komisyon oranı (%)
    private static final BigDecimal COMMISSION_RATE = new BigDecimal("0.10"); // %10

    /**
     * Kullanıcı için cüzdan oluştur (kayıt sırasında çağrılır)
     */
    @Transactional
    public Wallet createWalletForUser(User user) {
        if (walletRepository.existsByUserId(user.getId())) {
            return walletRepository.findByUserId(user.getId()).get();
        }

        Wallet wallet = Wallet.builder()
                .user(user)
                .balance(BigDecimal.ZERO)
                .frozenBalance(BigDecimal.ZERO)
                .totalEarnings(BigDecimal.ZERO)
                .totalSpent(BigDecimal.ZERO)
                .currency("TRY")
                .isActive(true)
                .build();

        wallet = walletRepository.save(wallet);
        log.info("Cüzdan oluşturuldu: User ID {}", user.getId());
        return wallet;
    }

    /**
     * Mevcut kullanıcının cüzdanını getir
     */
    public Wallet getCurrentUserWallet() {
        String username = SecurityContextHolder.getContext().getAuthentication().getName();
        return walletRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("Wallet", "username", username));
    }

    /**
     * Cüzdan bilgilerini getir
     */
    @Transactional(readOnly = true)
    public WalletDTO getWalletInfo() {
        Wallet wallet = getCurrentUserWallet();
        return convertToDTO(wallet);
    }

    /**
     * Cüzdan özeti (bakiye + son işlemler)
     */
    @Transactional(readOnly = true)
    public WalletSummaryDTO getWalletSummary() {
        Wallet wallet = getCurrentUserWallet();

        // Son 10 işlem
        Pageable pageable = PageRequest.of(0, 10, Sort.by(Sort.Direction.DESC, "createdAt"));
        List<Transaction> recentTransactions = transactionRepository.findRecentTransactions(wallet, pageable);

        return WalletSummaryDTO.builder()
                .wallet(convertToDTO(wallet))
                .totalDeposits(transactionRepository.getTotalDeposits(wallet))
                .totalWithdrawals(transactionRepository.getTotalWithdrawals(wallet))
                .pendingAmount(transactionRepository.getPendingAmount(wallet))
                .totalTransactions(transactionRepository.countByWallet(wallet))
                .recentTransactions(recentTransactions.stream()
                        .map(this::convertToDTO)
                        .collect(Collectors.toList()))
                .build();
    }

    /**
     * Bakiye yükleme
     * NOT: Gerçek ödeme entegrasyonu olmadığı için şimdilik direkt ekleniyor
     */
    @Transactional
    public TransactionDTO deposit(DepositRequest request) {
        Wallet wallet = getCurrentUserWallet();

        BigDecimal balanceBefore = wallet.getBalance();
        wallet.addBalance(request.getAmount());
        BigDecimal balanceAfter = wallet.getBalance();

        walletRepository.save(wallet);

        Transaction transaction = Transaction.builder()
                .wallet(wallet)
                .transactionReference(generateTransactionReference())
                .transactionType(TransactionType.DEPOSIT)
                .status(TransactionStatus.COMPLETED) // Şimdilik direkt tamamlanmış
                .amount(request.getAmount())
                .fee(BigDecimal.ZERO)
                .balanceBefore(balanceBefore)
                .balanceAfter(balanceAfter)
                .currency("TRY")
                .description(request.getDescription() != null ? request.getDescription() : "Bakiye yükleme")
                .paymentMethod(request.getPaymentMethod())
                .completedAt(LocalDateTime.now())
                .build();

        transaction = transactionRepository.save(transaction);
        log.info("Bakiye yüklendi: {} TL, Wallet ID: {}", request.getAmount(), wallet.getId());

        return convertToDTO(transaction);
    }

    /**
     * Bakiye çekme (Sürücüler için)
     * NOT: Gerçek ödeme entegrasyonu olmadığı için şimdilik pending durumunda bırakılıyor
     */
    @Transactional
    public TransactionDTO withdraw(WithdrawRequest request) {
        Wallet wallet = getCurrentUserWallet();

        // Yeterli bakiye kontrolü
        if (wallet.getAvailableBalance().compareTo(request.getAmount()) < 0) {
            throw new BadRequestException("Yetersiz bakiye. Mevcut kullanılabilir bakiye: " + wallet.getAvailableBalance());
        }

        BigDecimal balanceBefore = wallet.getBalance();
        wallet.subtractBalance(request.getAmount());
        BigDecimal balanceAfter = wallet.getBalance();

        walletRepository.save(wallet);

        Transaction transaction = Transaction.builder()
                .wallet(wallet)
                .transactionReference(generateTransactionReference())
                .transactionType(TransactionType.WITHDRAWAL)
                .status(TransactionStatus.PENDING) // Admin onayı bekleyecek
                .amount(request.getAmount())
                .fee(BigDecimal.ZERO)
                .balanceBefore(balanceBefore)
                .balanceAfter(balanceAfter)
                .currency("TRY")
                .description(request.getDescription() != null ? request.getDescription() : "Bakiye çekme talebi")
                .build();

        transaction = transactionRepository.save(transaction);
        log.info("Bakiye çekme talebi oluşturuldu: {} TL, Wallet ID: {}", request.getAmount(), wallet.getId());

        return convertToDTO(transaction);
    }

    /**
     * Kargo ücreti ödeme (Distributor'dan)
     * Kargo oluşturulduğunda çağrılır
     */
    @Transactional
    public Transaction processCargoPayment(Cargo cargo, BigDecimal amount) {
        Wallet distributorWallet = walletRepository.findByUserId(cargo.getDistributor().getId())
                .orElseThrow(() -> new ResourceNotFoundException("Wallet", "userId", cargo.getDistributor().getId()));

        // Yeterli bakiye kontrolü
        if (distributorWallet.getAvailableBalance().compareTo(amount) < 0) {
            throw new BadRequestException("Yetersiz bakiye. Kargo ücreti: " + amount);
        }

        BigDecimal balanceBefore = distributorWallet.getBalance();
        distributorWallet.subtractBalance(amount);
        distributorWallet.setTotalSpent(distributorWallet.getTotalSpent().add(amount));
        BigDecimal balanceAfter = distributorWallet.getBalance();

        walletRepository.save(distributorWallet);

        Transaction transaction = Transaction.builder()
                .wallet(distributorWallet)
                .cargo(cargo)
                .transactionReference(generateTransactionReference())
                .transactionType(TransactionType.CARGO_PAYMENT)
                .status(TransactionStatus.COMPLETED)
                .amount(amount)
                .fee(BigDecimal.ZERO)
                .balanceBefore(balanceBefore)
                .balanceAfter(balanceAfter)
                .currency("TRY")
                .description("Kargo #" + cargo.getId() + " ücreti")
                .completedAt(LocalDateTime.now())
                .build();

        transaction = transactionRepository.save(transaction);
        log.info("Kargo ücreti ödendi: {} TL, Cargo ID: {}", amount, cargo.getId());

        return transaction;
    }

    /**
     * Sürücüye kazanç ekleme
     * Kargo teslim edildiğinde çağrılır
     */
    @Transactional
    public Transaction processDriverEarning(Cargo cargo, BigDecimal totalAmount) {
        Wallet driverWallet = walletRepository.findByUserId(cargo.getDriver().getId())
                .orElseThrow(() -> new ResourceNotFoundException("Wallet", "userId", cargo.getDriver().getId()));

        // Komisyon hesapla
        BigDecimal commission = totalAmount.multiply(COMMISSION_RATE);
        BigDecimal driverEarning = totalAmount.subtract(commission);

        BigDecimal balanceBefore = driverWallet.getBalance();
        driverWallet.addBalance(driverEarning);
        driverWallet.setTotalEarnings(driverWallet.getTotalEarnings().add(driverEarning));
        BigDecimal balanceAfter = driverWallet.getBalance();

        walletRepository.save(driverWallet);

        // Sürücü kazancı işlemi
        Transaction driverTransaction = Transaction.builder()
                .wallet(driverWallet)
                .cargo(cargo)
                .transactionReference(generateTransactionReference())
                .transactionType(TransactionType.DRIVER_EARNING)
                .status(TransactionStatus.COMPLETED)
                .amount(driverEarning)
                .fee(commission)
                .balanceBefore(balanceBefore)
                .balanceAfter(balanceAfter)
                .currency("TRY")
                .description("Kargo #" + cargo.getId() + " teslimat kazancı (Komisyon: " + commission + " TL)")
                .completedAt(LocalDateTime.now())
                .build();

        driverTransaction = transactionRepository.save(driverTransaction);
        log.info("Sürücü kazancı eklendi: {} TL (Komisyon: {} TL), Cargo ID: {}", driverEarning, commission, cargo.getId());

        return driverTransaction;
    }

    /**
     * İşlem geçmişi
     */
    @Transactional(readOnly = true)
    public Page<TransactionDTO> getTransactionHistory(int page, int size, TransactionType type) {
        Wallet wallet = getCurrentUserWallet();
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));

        Page<Transaction> transactions;
        if (type != null) {
            transactions = transactionRepository.findByWalletAndTransactionType(wallet, type, pageable);
        } else {
            transactions = transactionRepository.findByWallet(wallet, pageable);
        }

        return transactions.map(this::convertToDTO);
    }

    /**
     * Kargo ücreti hesaplama (mesafeye göre)
     */
    public BigDecimal calculateCargoPrice(double distanceKm) {
        // Temel ücret + km başına ücret
        BigDecimal basePrice = new BigDecimal("20.00");
        BigDecimal perKmPrice = new BigDecimal("2.50");

        return basePrice.add(perKmPrice.multiply(BigDecimal.valueOf(distanceKm)));
    }

    // =============== HELPER METHODS ===============

    private String generateTransactionReference() {
        return "TXN-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }

    private WalletDTO convertToDTO(Wallet wallet) {
        return WalletDTO.builder()
                .id(wallet.getId())
                .userId(wallet.getUser().getId())
                .username(wallet.getUser().getUsername())
                .balance(wallet.getBalance())
                .frozenBalance(wallet.getFrozenBalance())
                .availableBalance(wallet.getAvailableBalance())
                .totalEarnings(wallet.getTotalEarnings())
                .totalSpent(wallet.getTotalSpent())
                .currency(wallet.getCurrency())
                .isActive(wallet.getIsActive())
                .createdAt(wallet.getCreatedAt())
                .updatedAt(wallet.getUpdatedAt())
                .build();
    }

    private TransactionDTO convertToDTO(Transaction transaction) {
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
