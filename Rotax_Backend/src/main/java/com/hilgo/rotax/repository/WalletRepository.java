package com.hilgo.rotax.repository;

import com.hilgo.rotax.entity.User;
import com.hilgo.rotax.entity.Wallet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface WalletRepository extends JpaRepository<Wallet, Long> {

    Optional<Wallet> findByUser(User user);

    Optional<Wallet> findByUserId(Long userId);

    @Query("SELECT w FROM Wallet w WHERE w.user.username = :username")
    Optional<Wallet> findByUsername(@Param("username") String username);

    boolean existsByUserId(Long userId);
}
