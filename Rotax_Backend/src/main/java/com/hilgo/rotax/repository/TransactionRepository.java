package com.hilgo.rotax.repository;

import com.hilgo.rotax.entity.Transaction;
import com.hilgo.rotax.entity.Wallet;
import com.hilgo.rotax.enums.TransactionStatus;
import com.hilgo.rotax.enums.TransactionType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long> {

    Optional<Transaction> findByTransactionReference(String transactionReference);

    Page<Transaction> findByWallet(Wallet wallet, Pageable pageable);

    Page<Transaction> findByWalletAndTransactionType(Wallet wallet, TransactionType type, Pageable pageable);

    Page<Transaction> findByWalletAndStatus(Wallet wallet, TransactionStatus status, Pageable pageable);

    List<Transaction> findByWalletOrderByCreatedAtDesc(Wallet wallet, Pageable pageable);

    @Query("SELECT t FROM Transaction t WHERE t.wallet = :wallet ORDER BY t.createdAt DESC")
    List<Transaction> findRecentTransactions(@Param("wallet") Wallet wallet, Pageable pageable);

    // Belirli bir kargoya ait işlemler
    List<Transaction> findByCargoId(Long cargoId);

    // Toplam yükleme
    @Query("SELECT COALESCE(SUM(t.amount), 0) FROM Transaction t WHERE t.wallet = :wallet AND t.transactionType = 'DEPOSIT' AND t.status = 'COMPLETED'")
    BigDecimal getTotalDeposits(@Param("wallet") Wallet wallet);

    // Toplam çekim
    @Query("SELECT COALESCE(SUM(t.amount), 0) FROM Transaction t WHERE t.wallet = :wallet AND t.transactionType = 'WITHDRAWAL' AND t.status = 'COMPLETED'")
    BigDecimal getTotalWithdrawals(@Param("wallet") Wallet wallet);

    // Bekleyen işlem toplamı
    @Query("SELECT COALESCE(SUM(t.amount), 0) FROM Transaction t WHERE t.wallet = :wallet AND t.status = 'PENDING'")
    BigDecimal getPendingAmount(@Param("wallet") Wallet wallet);

    // İşlem sayısı
    @Query("SELECT COUNT(t) FROM Transaction t WHERE t.wallet = :wallet")
    Integer countByWallet(@Param("wallet") Wallet wallet);

    // Tarih aralığına göre işlemler
    @Query("SELECT t FROM Transaction t WHERE t.wallet = :wallet AND t.createdAt BETWEEN :startDate AND :endDate ORDER BY t.createdAt DESC")
    List<Transaction> findByWalletAndDateRange(
            @Param("wallet") Wallet wallet,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate);

    // Admin: Tüm işlemleri listele
    Page<Transaction> findAllByOrderByCreatedAtDesc(Pageable pageable);

    // Admin: Duruma göre işlemler
    Page<Transaction> findByStatusOrderByCreatedAtDesc(TransactionStatus status, Pageable pageable);
}
