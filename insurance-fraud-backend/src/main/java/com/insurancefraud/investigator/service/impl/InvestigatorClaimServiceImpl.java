package com.insurancefraud.investigator.service.impl;

import com.insurancefraud.claim.repository.ClaimRepo;
import com.insurancefraud.common.exception.ResourceNotFoundException;
import com.insurancefraud.common.security.CurrentUserService;
import com.insurancefraud.entity.Claim;
import com.insurancefraud.entity.User;
import com.insurancefraud.enums.ClaimStatus;
import com.insurancefraud.enums.FraudStatus;
import com.insurancefraud.investigator.dto.InvestigatorClaimReviewRequestDto;
import com.insurancefraud.investigator.dto.InvestigatorClaimReviewResponseDto;
import org.springframework.transaction.annotation.Transactional;
import com.insurancefraud.investigator.dto.InvestigatorClaimResponseDto;
import com.insurancefraud.investigator.service.InvestigatorClaimService;
import com.insurancefraud.repository.UserRepo;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

@Service
@Slf4j
public class InvestigatorClaimServiceImpl implements InvestigatorClaimService {

    private final CurrentUserService currentUserService;
    private final ClaimRepo claimRepo;


    public InvestigatorClaimServiceImpl(CurrentUserService currentUserService, ClaimRepo claimRepo) {
        this.currentUserService = currentUserService;
        this.claimRepo = claimRepo;
    }

    @Override
    @Transactional(readOnly = true)
    public List<InvestigatorClaimResponseDto> getAssignedClaimsForInvestigator() {
        User investigator = currentUserService.getCurrentActiveUser();
        List<Claim> claims = claimRepo.findByAssignedInvestigatorAndIsDeletedFalse(investigator);
        log.info("INVESTIGATOR : Found {} claims assigned to investigator {}", claims.size(), investigator.getEmail());
        return claims
                .stream()
                .map(claim ->
                        new InvestigatorClaimResponseDto(
                                claim.getClaimId(),
                                claim.getClaimNumber(),
                                claim.getClaimType(),
                                claim.getClaimAmount(),
                                claim.getClaimStatus(),
                                claim.getFraudStatus(),
                                claim.getCreatedAt(),
                                claim.getIncidentCity()
                        )
                )
                .toList();
    }

    @Transactional
    @Override
    public InvestigatorClaimReviewResponseDto reviewClaimById(Long claimId, InvestigatorClaimReviewRequestDto requestDto) {

        User investigator = currentUserService.getCurrentActiveUser();

        Claim claim = claimRepo
                .findByClaimIdAndAssignedInvestigatorAndClaimStatusAndIsDeletedFalse(claimId, investigator, ClaimStatus.UNDER_REVIEW)
                        .orElseThrow(() -> new ResourceNotFoundException("Claim not found or not assigned"));

        if (claim.getFraudStatus() != FraudStatus.PENDING_ANALYSIS) {
            log.warn("Claim {} already reviewed by investigator {}", claim.getClaimNumber(), investigator.getEmail());
            throw new IllegalStateException("Claim already reviewed");
        }

        claim.setReviewNotes(requestDto.getReviewNotes());
        claim.setFraudStatus(requestDto.getFraudStatus());
        claimRepo.save(claim);
        log.info(
                "Investigator {} reviewed claim {}",
                investigator.getEmail(),
                claim.getClaimNumber()
        );

        return new InvestigatorClaimReviewResponseDto(
                claim.getClaimId(),
                claim.getClaimNumber(),
                claim.getClaimStatus(),
                claim.getFraudStatus(),
                claim.getReviewNotes(),
                investigator.getFullName(),
                claim.getUpdatedAt()
        );
    }
}
