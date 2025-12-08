package com.hilgo.rotax.repository;

import com.hilgo.rotax.entity.User;
import com.hilgo.rotax.enums.Roles;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User,Long> {
    Optional<User> findByUsername(String username);
    Optional<User> findByEmail(String email);
    Optional<User> findByPhoneNumber(String phoneNumber);
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
    boolean existsByPhoneNumber(String phoneNumber);

    // Admin queries
    Page<User> findByRole(Roles role, Pageable pageable);
    
    long countByRole(Roles role);
    
    @Query("SELECT COUNT(u) FROM User u WHERE CAST(u.createdAt AS date) = :date")
    long countByCreatedAtDate(@Param("date") LocalDate date);
}
