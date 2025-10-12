package com.hilgo.rotax.repository;

import com.hilgo.rotax.entity.Cargo;
import com.hilgo.rotax.entity.Distributor;
import com.hilgo.rotax.entity.Driver;
import com.hilgo.rotax.enums.CargoSituation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CargoRepository extends JpaRepository<Cargo, Long> {
    List<Cargo> findByDistributor(Distributor distributor);
    
    List<Cargo> findByDriver(Driver driver);
    
    List<Cargo> findByCargoSituation(CargoSituation situation);
    
    List<Cargo> findByDistributorAndCargoSituation(Distributor distributor, CargoSituation situation);
    
    List<Cargo> findByDriverAndCargoSituation(Driver driver, CargoSituation situation);
    
    Optional<Cargo> findByVerificationCode(String verificationCode);
    
    @Query("SELECT c FROM Cargo c WHERE c.cargoSituation = :situation AND " +
           "ST_DistanceSphere(ST_MakePoint(c.selfLocation.longitude, c.selfLocation.latitude), " +
           "ST_MakePoint(:longitude, :latitude)) <= :radiusInMeters")
    List<Cargo> findNearbyCargos(CargoSituation situation, Double latitude, Double longitude, Double radiusInMeters);
}