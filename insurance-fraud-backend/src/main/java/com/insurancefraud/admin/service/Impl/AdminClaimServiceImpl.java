package com.insurancefraud.admin.service.Impl;

import com.insurancefraud.admin.dto.ClaimDecisionRequestDto;
import com.insurancefraud.admin.dto.ClaimDecisionResponseDto;
import com.insurancefraud.admin.dto.InvestigatorsWorkloadResDto;
import com.insurancefraud.admin.service.AdminClaimService;
import com.insurancefraud.common.exception.ResourceNotFoundException;
import com.insurancefraud.common.security.CurrentUserService;
import com.insurancefraud.entity.Claim;
import com.insurancefraud.enums.FraudStatus;
import org.springframework.transaction.annotation.Transactional;
import com.insurancefraud.entity.User;
import com.insurancefraud.enums.ClaimStatus;
import com.insurancefraud.enums.RoleCode;
import com.insurancefraud.enums.UserStatus;
import com.insurancefraud.claim.repository.ClaimRepo;
import com.insurancefraud.repository.UserRepo;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;

@Service
@Slf4j
public class AdminClaimServiceImpl implements AdminClaimService {

    private final CurrentUserService currentUserService;
    private final UserRepo userRepo;;
    private final ClaimRepo claimRepo;

    public AdminClaimServiceImpl(CurrentUserService currentUserService,UserRepo userRepo,ClaimRepo claimRepo) {
        this.currentUserService = currentUserService;
        this.userRepo = userRepo;
        this.claimRepo =claimRepo;
    }

    @Override
    @Transactional
        public void assignInvestigatorToClaim(Long claimId, Long investigatorId) {
        User admin = currentUserService.getCurrentActiveUser();

        Claim claim = claimRepo.findByClaimIdAndTenantAndIsDeletedFalse(claimId, admin.getTenant())
                        .orElseThrow(() -> new ResourceNotFoundException("Claim not found"));

        User investigator =
                userRepo
                        .findByTenantAndRole_RoleCodeAndIsDeletedFalseAndStatusAndUserId(
                                admin.getTenant(),
                                RoleCode.INVESTIGATOR,
                                UserStatus.ACTIVE,
                                investigatorId
                        )
                        .orElseThrow(() ->
                                new ResourceNotFoundException(
                                        "Investigator not found"
                                )
                        );

        // PREVENT REASSIGNMENT
        if (claim.getAssignedInvestigator() != null) {
            throw new IllegalStateException(
                    "Claim already assigned to investigator"
            );
        }
        claim.setAssignedInvestigator(investigator);
        claim.setClaimStatus(ClaimStatus.UNDER_REVIEW);
        claimRepo.save(claim);

        log.info(
                "Admin {} assigned investigator {} to claim {}",
                admin.getEmail(),
                investigator.getEmail(),
                claim.getClaimNumber()
        );
    }

    @Override
    @Transactional(readOnly = true)
    public List<InvestigatorsWorkloadResDto> getInvestigatorsWorkload() {
        User admin = currentUserService.getCurrentActiveUser();

        List<User> investigators =
                userRepo
                        .findByTenantAndRole_RoleCodeAndIsDeletedFalseAndStatus(
                                admin.getTenant(),
                                RoleCode.INVESTIGATOR,
                                UserStatus.ACTIVE
                        );

        log.info(
                "Retrieved investigator workload for tenant {}",
                admin.getTenant().getTenantCode()
        );
        return investigators
                .stream().
                map(investigator -> {
                    Long activeClaims = claimRepo.
                            countByAssignedInvestigatorAndClaimStatusNotAndIsDeletedFalse(investigator, ClaimStatus.CLOSED);

                   return new InvestigatorsWorkloadResDto(
                        investigator.getUserId(),
                        investigator.getFullName(),
                        activeClaims
                      );
                }
                ).toList();
    }

    @Transactional
    @Override
    public ClaimDecisionResponseDto approveClaim(
            Long claimId,
            ClaimDecisionRequestDto requestDto
    ) {

        User admin = currentUserService.getCurrentActiveUser();

        Claim claim =claimRepo.findByClaimIdAndClaimStatusAndIsDeletedFalse(claimId, ClaimStatus.UNDER_REVIEW)
                        .orElseThrow(() -> new ResourceNotFoundException("Claim not found or not under review"));

        if (claim.getFraudStatus() == FraudStatus.PENDING_ANALYSIS) {
            throw new IllegalStateException("Claim investigation not completed");
        }
        if (claim.getFraudStatus() == FraudStatus.CONFIRMED) {
            throw new IllegalStateException("Fraudulent claims cannot be approved");
        }
        if (claim.getClaimStatus() == ClaimStatus.APPROVED) {
            throw new IllegalStateException("Claim already approved");
        }

        claim.setDecisionNotes(requestDto.getDecisionNotes());
        claim.setClaimStatus(ClaimStatus.APPROVED);
        claimRepo.save(claim);

        log.info(
                "Admin {} approved claim {}",
                admin.getEmail(),
                claim.getClaimNumber()
        );
        return new ClaimDecisionResponseDto(
                claim.getClaimId(),
                claim.getClaimNumber(),
                claim.getClaimStatus(),
                claim.getDecisionNotes(),
                claim.getFraudStatus(),
                admin.getEmail(),
                claim.getUpdatedAt()
        );
    }

    @Transactional
    @Override
    public ClaimDecisionResponseDto rejectClaim(
            Long claimId,
            ClaimDecisionRequestDto requestDto
    ) {
        User admin = currentUserService.getCurrentActiveUser();
        Claim claim =
                claimRepo.findByClaimIdAndClaimStatusAndIsDeletedFalse(claimId, ClaimStatus.UNDER_REVIEW)
                        .orElseThrow(() ->
                                new ResourceNotFoundException("Claim not found or not under review"));

        if (claim.getFraudStatus() == FraudStatus.PENDING_ANALYSIS) {
            throw new IllegalStateException("Claim investigation not completed");
        }

        if (claim.getClaimStatus() == ClaimStatus.REJECTED) {
            throw new IllegalStateException("Claim already rejected");
        }
        claim.setDecisionNotes(requestDto.getDecisionNotes());
        claim.setClaimStatus(ClaimStatus.REJECTED);
        claimRepo.save(claim);

        log.info(
                "Admin {} rejected claim {}",
                admin.getEmail(),
                claim.getClaimNumber()
        );

        return new ClaimDecisionResponseDto(
                claim.getClaimId(),
                claim.getClaimNumber(),
                claim.getClaimStatus(),
                claim.getDecisionNotes(),
                claim.getFraudStatus(),
                admin.getEmail(),
                claim.getUpdatedAt()
        );
    }
}
