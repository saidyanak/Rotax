package com.hilgo.rotax.repository;

import com.hilgo.rotax.entity.Driver;
import com.hilgo.rotax.enums.DriverStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DriverRepository extends JpaRepository<Driver, Long> {
    Optional<Driver> findByUsername(String username);
    
    @Query("SELECT d FROM Driver d WHERE d.driverStatus = :status")
    List<Driver> findAllByDriverStatus(DriverStatus status);
    
    @Query("SELECT d FROM Driver d WHERE d.driverStatus = :status AND " +
           "ST_DistanceSphere(ST_MakePoint(d.location.longitude, d.location.latitude), " +
           "ST_MakePoint(:longitude, :latitude)) <= :radiusInMeters")
    List<Driver> findNearbyDrivers(DriverStatus status, Double latitude, Double longitude, Double radiusInMeters);

    boolean existsByTc(String tc);
}