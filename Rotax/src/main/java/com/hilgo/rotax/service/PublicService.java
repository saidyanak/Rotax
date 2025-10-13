package com.hilgo.rotax.service;

import com.hilgo.rotax.dto.*;
import com.hilgo.rotax.entity.Cargo;
import com.hilgo.rotax.entity.Driver;
import com.hilgo.rotax.entity.Review;
import com.hilgo.rotax.enums.CargoSituation;
import com.hilgo.rotax.enums.ReviewerType;
import com.hilgo.rotax.repository.CargoRepository;
import com.hilgo.rotax.repository.ReviewRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class PublicService {

    private final CargoRepository cargoRepository;
    private final ReviewRepository reviewRepository;

    public TrackingResponse trackCargo(String trackingCode) {
        Cargo cargo = cargoRepository.findByVerificationCode(trackingCode)
                .orElseThrow(() -> new RuntimeException("Cargo not found with tracking code: " + trackingCode));
        
        // Calculate ETA based on distance and average speed (if cargo is being delivered)
        Double eta = null;
        if (cargo.getCargoSituation() == CargoSituation.PICKED_UP && 
            cargo.getDriver() != null && 
            cargo.getDriver().getLocation() != null) {
            
            // Calculate distance between driver's current location and delivery location
            double distance = calculateDistance(
                    cargo.getDriver().getLocation().getLatitude(),
                    cargo.getDriver().getLocation().getLongitude(),
                    cargo.getTargetLocation().getLatitude(),
                    cargo.getTargetLocation().getLongitude());
            
            // Assume average speed of 40 km/h
            double averageSpeed = 40.0;
            
            // Calculate ETA in minutes
            eta = (distance / averageSpeed) * 60;
        }
        
        return TrackingResponse.builder()
                .trackingCode(trackingCode)
                .status(cargo.getCargoSituation())
                .currentLocation(cargo.getDriver() != null && cargo.getDriver().getLocation() != null ? 
                        mapToLocationDTO(cargo.getDriver().getLocation()) : 
                        mapToLocationDTO(cargo.getSelfLocation()))
                .destinationLocation(mapToLocationDTO(cargo.getTargetLocation()))
                .driverName(cargo.getDriver() != null ? 
                        cargo.getDriver().getFirstName() + " " + cargo.getDriver().getLastName() : null)
                .driverPhone(cargo.getDriver() != null ? cargo.getDriver().getPhoneNumber() : null)
                .estimatedTimeOfArrival(eta)
                .deliveryTime(cargo.getDeliveredTime())
                .deliveryNote(cargo.getDescription())
                .build();
    }

    @Transactional
    public MessageResponse addDeliveryNote(String trackingCode, DeliveryNoteRequest request) {
        Cargo cargo = cargoRepository.findByVerificationCode(trackingCode)
                .orElseThrow(() -> new RuntimeException("Cargo not found with tracking code: " + trackingCode));
        
        // Update delivery note
        cargo.setDescription(request.getNote());
        cargoRepository.save(cargo);
        
        return new MessageResponse("Delivery note added successfully", true);
    }

    @Transactional
    public MessageResponse addReview(String trackingCode, ReviewDTO reviewDTO) {
        Cargo cargo = cargoRepository.findByVerificationCode(trackingCode)
                .orElseThrow(() -> new RuntimeException("Cargo not found with tracking code: " + trackingCode));
        
        // Check if cargo is delivered
        if (cargo.getCargoSituation() != CargoSituation.DELIVERED) {
            throw new RuntimeException("Cannot review a cargo that has not been delivered yet");
        }
        
        // Check if driver exists
        Driver driver = cargo.getDriver();
        if (driver == null) {
            throw new RuntimeException("No driver assigned to this cargo");
        }
        
        // Create review
        Review review = new Review();
        review.setRating(reviewDTO.getRating());
        review.setComment(reviewDTO.getComment());
        review.setReviewerType(ReviewerType.END_USER);
        review.setDriver(driver);
        review.setReviewerName("Recipient");
        
        reviewRepository.save(review);
        
        return new MessageResponse("Review added successfully", true);
    }

    private LocationDTO mapToLocationDTO(com.hilgo.rotax.entity.Location location) {
        if (location == null) {
            return null;
        }
        
        return LocationDTO.builder()
                .latitude(location.getLatitude())
                .longitude(location.getLongitude())
                .address(location.getAddress())
                .city(location.getCity())
                .district(location.getDistrict())
                .postalCode(location.getPostalCode())
                .build();
    }

    // Helper method to calculate distance between two points using Haversine formula
    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371; // Radius of the earth in km
        
        double latDistance = Math.toRadians(lat2 - lat1);
        double lonDistance = Math.toRadians(lon2 - lon1);
        
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
        
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        
        return R * c; // Distance in km
    }
}