package com.hilgo.rotax.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.hilgo.rotax.entity.UserDocument;
import com.hilgo.rotax.enums.VerificationStatus;

public interface UserDocumentRepository extends JpaRepository<UserDocument, Long> {
    List<UserDocument> findByVerificationStatus(VerificationStatus status);
}