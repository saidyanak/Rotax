package com.hilgo.rotax.repository;

import com.hilgo.rotax.entity.Distributor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface DistributorRepository extends JpaRepository<Distributor, Long> {
    Optional<Distributor> findByUsername(String username);

    boolean existsByVkn(String vkn);
}