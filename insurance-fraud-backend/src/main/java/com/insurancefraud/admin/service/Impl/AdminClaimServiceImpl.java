package com.insurancefraud.admin.service.Impl;

import com.insurancefraud.admin.dto.InvestigatorsWorkloadResDto;
import com.insurancefraud.admin.service.AdminClaimService;
import com.insurancefraud.common.exception.ResourceNotFoundException;
import com.insurancefraud.common.security.CurrentUserService;
import com.insurancefraud.entity.Claim;
import org.springframework.transaction.annotation.Transactional;
import com.insurancefraud.entity.User;
import com.insurancefraud.enums.ClaimStatus;
import com.insurancefraud.enums.RoleCode;
import com.insurancefraud.enums.UserStatus;
import com.insurancefraud.claim.repository.ClaimRepo;
import com.insurancefraud.repository.UserRepo;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
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
}
