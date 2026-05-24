package com.insurancefraud.service.impl;

import com.insurancefraud.dto.ClaimRequestDto;
import com.insurancefraud.dto.ClaimResponseDto;
import com.insurancefraud.dto.PaginatedClaimResponse;
import com.insurancefraud.entity.*;
import com.insurancefraud.exception.UserNotFoundException;
import com.insurancefraud.repository.ClaimRepo;
import com.insurancefraud.repository.UserRepo;
import com.insurancefraud.service.ClaimService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.modelmapper.ModelMapper;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.data.domain.Pageable;
import java.time.Year;
import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Service
public class ClaimServiceImpl implements ClaimService {

    private final CurrentUserServiceImpl currentUserService;
    private final ClaimRepo claimRepo;
    private final UserRepo userRepo;
    private final ModelMapper mapper;


    public String generateClaimNumber(String tenantCode) {
        int year = Year.now().getValue();
        Long nextSequenceValue = claimRepo.getNextSequenceValue();
        return String.format("%s-%d-%05d", tenantCode, year, nextSequenceValue);

    }

    @Transactional
    @Override
    public ClaimResponseDto createClaim(ClaimRequestDto requestDto) {
        User currentUser = currentUserService.getCurrentActiveUser();

        User user = userRepo.findById(currentUser.getUserId())
                .orElseThrow(() -> new UserNotFoundException("User not found"));

        Tenant tenant = user.getTenant();
        String claimNumber = generateClaimNumber(tenant.getTenantCode());

        Claim claim = mapper.map(requestDto, Claim.class);
        claim.setTenant(tenant);
        claim.setUser(user);
        claim.setClaimNumber(claimNumber);
        claim.setFraudStatus(FraudStatus.PENDING_ANALYSIS);
        claim.setClaimStatus(ClaimStatus.PENDING);
        claim = claimRepo.save(claim);
        log.info("Claim created with ID: {}", claim.getClaimId());
        return mapper.map(claim, ClaimResponseDto.class);

    }

    @Override
    @Transactional(readOnly = true)
    public PaginatedClaimResponse getClaimsForCurrentUser(
            int pageNumber,
            int pageSize,
            String sortBy,
            String sortDir
    ) {
        User currentUser =
                currentUserService.getCurrentActiveUser();

        User user = userRepo.findById(currentUser.getUserId())
                .orElseThrow(() ->
                        new UserNotFoundException(
                                "User not found"
                        )
                );
        // PAGE SIZE PROTECTION
        if (pageSize > 50) {
            pageSize = 50;
        }
        if (pageSize < 1) {
            pageSize = 10;
        }
        // VALID SORT FIELDS
        List<String> allowedSortFields = List.of(
                "createdAt",
                "claimAmount",
                "incidentDate",
                "claimStatus"
        );

        if (!allowedSortFields.contains(sortBy)) {
            sortBy = "createdAt";
        }

        // SORT DIRECTION
        Sort sort = sortDir.equalsIgnoreCase("ASC") ? Sort.by(sortBy).ascending() : Sort.by(sortBy).descending();
        Pageable pageable = PageRequest.of(pageNumber, pageSize, sort);
        Page<Claim> claimPages = claimRepo.findByUserAndIsDeletedFalse(user, pageable);

        List<ClaimResponseDto> dtoList =
                claimPages.getContent()
                        .stream()
                        .map(claim ->
                                mapper.map(
                                        claim,
                                        ClaimResponseDto.class
                                )
                        )
                        .toList();

        log.info("Retrieved {} claims for user {}", dtoList.size(), user.getEmail());
        PaginatedClaimResponse response = new PaginatedClaimResponse();
        response.setContent(dtoList);
        response.setTotalElements(claimPages.getTotalElements());
        response.setTotalPages(claimPages.getTotalPages());
        response.setPageNo(claimPages.getNumber());
        response.setPageSize(claimPages.getSize());
        response.setFirst(claimPages.isFirst());
        response.setLast(claimPages.isLast());
        response.setSorted(claimPages.getSort().isSorted());
        response.setSortBy(sortBy);
        response.setNextPage(claimPages.hasNext() ? (long) claimPages.getNumber() + 1 : null);
        response.setPreviousPage(claimPages.hasPrevious() ? (long) claimPages.getNumber() - 1 : null);
        return response;
    }
}
