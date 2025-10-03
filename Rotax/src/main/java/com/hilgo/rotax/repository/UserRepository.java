package com.hilgo.rotax.repository;

import com.hilgo.rotax.entity.User;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository {
    Optional<User> findByUsername(String username);
    Optional<User> findByMail(String mail);
    Optional<User> findByPhoneNumber(String phoneNumber);
    boolean existsByUsername(String username);
    boolean existsByMail(String mail);
    boolean existsByPhoneNumber(String phoneNumber);
}
