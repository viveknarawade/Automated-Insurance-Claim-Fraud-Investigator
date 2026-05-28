package com.insurancefraud.document.repository;

import com.insurancefraud.entity.ClaimDocument;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ClaimDocumentRepo extends JpaRepository<ClaimDocument,Long>  {
    List<ClaimDocument> findByClaim_ClaimIdAndIsDeletedFalse(Long claimId);

    Optional<ClaimDocument>  findByClaim_User_UserIdAndClaimDocIdAndIsDeletedFalse(Long userId, Long documentId);
}
