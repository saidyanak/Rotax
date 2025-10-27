package com.hilgo.rotax.repository;

import com.hilgo.rotax.entity.Driver;
import com.hilgo.rotax.entity.Review;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReviewRepository extends JpaRepository<Review, Long> {
    List<Review> findByDriverId(Long driverId);
    
    @Query("SELECT AVG(r.rating) FROM Review r WHERE r.driver.id = :driverId")
    Double getAverageRatingForDriver(Long driverId);
}