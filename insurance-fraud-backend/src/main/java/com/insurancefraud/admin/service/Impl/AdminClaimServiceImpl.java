package com.insurancefraud.admin.service.Impl;

import com.insurancefraud.admin.dto.*;
import com.insurancefraud.claim.dto.ClaimSummaryResponseDto;
import com.insurancefraud.admin.service.AdminClaimService;
import com.insurancefraud.claim.dto.PaginatedClaimResponse;
import com.insurancefraud.common.exception.ResourceNotFoundException;
import com.insurancefraud.common.security.CurrentUserService;
import com.insurancefraud.entity.Claim;
import com.insurancefraud.enums.*;
import org.modelmapper.ModelMapper;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.transaction.annotation.Transactional;
import com.insurancefraud.entity.User;
import com.insurancefraud.claim.repository.ClaimRepo;
import com.insurancefraud.repository.UserRepo;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@Slf4j
public class AdminClaimServiceImpl implements AdminClaimService {

    private final CurrentUserService currentUserService;
    private final UserRepo userRepo;
    private final ModelMapper mapper;
    private final ClaimRepo claimRepo;

    public AdminClaimServiceImpl(CurrentUserService currentUserService,UserRepo userRepo,ClaimRepo claimRepo,ModelMapper mapper) {
        this.currentUserService = currentUserService;
        this.userRepo = userRepo;
        this.claimRepo =claimRepo;
        this.mapper =mapper;
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
    public ClaimDecisionResponseDto approveClaim(Long claimId, ClaimDecisionRequestDto requestDto) {

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
    public ClaimDecisionResponseDto rejectClaim(Long claimId, ClaimDecisionRequestDto requestDto) {
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

    @Transactional(readOnly = true)
    @Override
    public DashboardResponseDto getAdminDashboard() {
        User admin = currentUserService.getCurrentActiveUser();

        Long totalClaims = claimRepo.countByTenantAndIsDeletedFalse(admin.getTenant());
        Long pendingClaims = claimRepo.countByTenantAndClaimStatusAndIsDeletedFalse(admin.getTenant(), ClaimStatus.PENDING);
        Long underReviewClaims = claimRepo.countByTenantAndClaimStatusAndIsDeletedFalse(admin.getTenant(), ClaimStatus.UNDER_REVIEW);
        Long approvedClaims = claimRepo.countByTenantAndClaimStatusAndIsDeletedFalse(admin.getTenant(), ClaimStatus.APPROVED);
        Long rejectedClaims = claimRepo.countByTenantAndClaimStatusAndIsDeletedFalse(admin.getTenant(), ClaimStatus.REJECTED);
        Long suspectedFraudClaims = claimRepo.countByTenantAndFraudStatusAndIsDeletedFalse(admin.getTenant(), FraudStatus.SUSPECTED);
        Long confirmedFraudClaims = claimRepo.countByTenantAndFraudStatusAndIsDeletedFalse(admin.getTenant(), FraudStatus.CONFIRMED);
        Long activeClaims =  pendingClaims + underReviewClaims;

        log.info(
                "Admin {} retrieved dashboard data for tenant {}",
                admin.getEmail(),
                admin.getTenant().getTenantCode()
        );

        return new DashboardResponseDto(
                totalClaims,
                pendingClaims,
                approvedClaims,
                rejectedClaims,
                suspectedFraudClaims,
                underReviewClaims,
                confirmedFraudClaims,
                activeClaims
        );
    }

    @Transactional(readOnly = true)
    @Override
    public List<ClaimSummaryResponseDto> getUnassignedClaimsForTenant() {
        User admin = currentUserService.getCurrentActiveUser();

        String tenantCode = admin.getTenant().getTenantCode();
        List<Claim> claims = claimRepo.findByTenant_TenantCodeAndIsDeletedFalseAndAssignedInvestigatorIsNull(tenantCode);

        log.info("Admin {} requested unassigned claims for tenant {}. Returning {} claims",
                admin.getEmail(), tenantCode, claims.size());

        return claims.stream().map(c -> {
            ClaimSummaryResponseDto dto = new ClaimSummaryResponseDto();
            dto.setClaimId(c.getClaimId());
            dto.setClaimNumber(c.getClaimNumber());
            dto.setClaimType(c.getClaimType());
            dto.setClaimAmount(c.getClaimAmount());
            dto.setClaimStatus(c.getClaimStatus());
            dto.setFraudStatus(c.getFraudStatus());
            dto.setIncidentDate(c.getIncidentDate());
            dto.setIncidentCity(c.getIncidentCity());
            dto.setCreatedAt(c.getCreatedAt());
            return dto;
        }).toList();
    }


    @Override
    @Transactional(readOnly = true)
    public PaginatedAdminClaimResponseDto getAllClaims(int pageNumber,int pageSize, ClaimSortField sortBy, String sortDir) {

        User admin = currentUserService.getCurrentActiveUser();

        // PAGE SIZE PROTECTION
        if (pageSize > 50) {
            pageSize = 50;
        }
        if (pageSize < 1) {
            pageSize = 10;
        }

        // SORT DIRECTION
        Sort sort =
                sortDir.equalsIgnoreCase("ASC")
                        ? Sort.by(sortBy.getFieldName()).ascending()
                        : Sort.by(sortBy.getFieldName()).descending();

        Pageable pageable = PageRequest.of(pageNumber, pageSize, sort);


        Page<Claim> claimPages =
                claimRepo.findByTenant_TenantCodeAndIsDeletedFalse(
                        admin.getTenant().getTenantCode(),
                        pageable
                );


        List<ClaimSummaryResponseDto> dtoList =
                claimPages.getContent()
                        .stream()
                        .map(claim ->
                                mapper.map(
                                        claim,
                                        ClaimSummaryResponseDto.class
                                )
                        )
                        .toList();


        log.info("Retrieved {} claims for user {}", dtoList.size(), admin.getEmail());
        PaginatedAdminClaimResponseDto response = new PaginatedAdminClaimResponseDto();
        response.setContent(dtoList);
        response.setTotalElements(claimPages.getTotalElements());
        response.setTotalPages(claimPages.getTotalPages());
        response.setPageNo(claimPages.getNumber());
        response.setPageSize(claimPages.getSize());
        response.setFirst(claimPages.isFirst());
        response.setLast(claimPages.isLast());
        response.setSorted(claimPages.getSort().isSorted());
        response.setSortBy(sortBy.name());
        response.setNextPage(claimPages.hasNext() ? (long) claimPages.getNumber() + 1 : null);
        response.setPreviousPage(claimPages.hasPrevious() ? (long) claimPages.getNumber() - 1 : null);
        return response;
    }
}

