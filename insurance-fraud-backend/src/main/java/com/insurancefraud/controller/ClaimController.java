package com.insurancefraud.controller;

import com.insurancefraud.dto.ClaimRequestDto;
import com.insurancefraud.dto.ClaimResponseDto;
import com.insurancefraud.dto.PaginatedClaimResponse;
import com.insurancefraud.payload.ApiResponse;
import com.insurancefraud.service.ClaimService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Value;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor
@Tag(name = "ClaimController", description = "Endpoints for managing insurance claims")
@RequestMapping("/api/v1/claims")
public class ClaimController {

    private final ClaimService claimService;

    @Operation(summary = "Create a new insurance claim", description = "Allows users to submit a new insurance claim with all necessary details.")
    @PostMapping
    public ResponseEntity<ApiResponse<ClaimResponseDto>> createClaim(@Valid @RequestBody ClaimRequestDto requestDto) {
        ClaimResponseDto claimResponse = claimService.createClaim(requestDto);

        ApiResponse<ClaimResponseDto> response = new ApiResponse<>(
                true,
                "Claim created successfully",
                201,
                Instant.now(),
                claimResponse
        );
        return ResponseEntity.ok(response);
    }

    @GetMapping("/my")
    public ResponseEntity<ApiResponse<PaginatedClaimResponse>> getMyClaims(
            @RequestParam(name = "pageNo", defaultValue = "0", required = false) int pageNumber,
            @RequestParam(name = "pageSize", defaultValue = "10", required = false) int pageSize,
            @RequestParam(name = "sortBy", defaultValue = "createdAt", required = false) String sortBy,
            @RequestParam(name = "sortDir", defaultValue = "DESC", required = false) String sortDir
    ) {
        PaginatedClaimResponse data =
                claimService.getClaimsForCurrentUser(
                        pageNumber,
                        pageSize,
                        sortBy,
                        sortDir
                );

        ApiResponse<PaginatedClaimResponse> response =
                new ApiResponse<>(
                        true,
                        "Claims retrieved successfully",
                        200,
                        Instant.now(),
                        data
                );
        return ResponseEntity.ok(response);
    }


}
