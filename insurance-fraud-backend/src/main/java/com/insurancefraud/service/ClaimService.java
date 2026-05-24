package com.insurancefraud.service;


import com.insurancefraud.dto.ClaimDetailResponseDto;
import com.insurancefraud.dto.ClaimRequestDto;
import com.insurancefraud.dto.ClaimSummaryResponseDto;
import com.insurancefraud.dto.PaginatedClaimResponse;
import com.insurancefraud.entity.ClaimSortField;
import jakarta.validation.Valid;

public interface ClaimService {
    ClaimSummaryResponseDto createClaim(@Valid ClaimRequestDto requestDto);
    PaginatedClaimResponse getClaimsForCurrentUser(int pageNumber, int pageSize, ClaimSortField sortBy, String sortDir);

    ClaimDetailResponseDto getClaimById(Long claimId);
}
