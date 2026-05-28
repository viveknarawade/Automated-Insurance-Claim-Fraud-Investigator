package com.insurancefraud.repository;

import com.insurancefraud.entity.Claim;
import com.insurancefraud.entity.Tenant;
import com.insurancefraud.entity.User;
import com.insurancefraud.enums.ClaimStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;


import java.util.Optional;


@Repository
public interface ClaimRepo extends JpaRepository<Claim, Long> {
    @Query(value = "SELECT nextval('claim_number_seq')", nativeQuery = true)
    Long getNextSequenceValue();

    Page<Claim> findByUserAndIsDeletedFalse(User user, Pageable pageable);

    Optional<Claim>  findByUserAndClaimIdAndIsDeletedFalse(User user, Long claimId);

    Optional<Claim> findByClaimIdAndIsDeletedFalse(Long claimId);

    Long countByAssignedInvestigatorAndClaimStatusNotAndIsDeletedFalse(
            User investigator,
            ClaimStatus status
    );

    Optional<Claim> findByClaimIdAndTenantAndIsDeletedFalse(
            Long claimId,
            Tenant tenant
    );


}
