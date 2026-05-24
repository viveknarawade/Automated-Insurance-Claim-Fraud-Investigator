package com.insurancefraud.service;


import com.insurancefraud.dto.ClaimRequestDto;
import com.insurancefraud.dto.ClaimResponseDto;
import com.insurancefraud.dto.PaginatedClaimResponse;
import jakarta.validation.Valid;

import java.util.List;

public interface ClaimService {
    ClaimResponseDto createClaim(@Valid ClaimRequestDto requestDto);
    PaginatedClaimResponse getClaimsForCurrentUser(int pageNumber, int pageSize,String sortBy,String sortDir);
}
