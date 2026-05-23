package com.insurancefraud.controller;

import com.insurancefraud.dto.ClaimRequestDto;
import com.insurancefraud.dto.ClaimResponseDto;
import com.insurancefraud.payload.ApiResponse;
import com.insurancefraud.service.ClaimService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.Value;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;

@Slf4j
@RestController
@RequiredArgsConstructor
@Tag(name = "ClaimController", description = "Endpoints for managing insurance claims")
@RequestMapping("/api/v1/claims")
public class ClaimController {

    private final ClaimService claimService;

    ResponseEntity<ApiResponse<ClaimResponseDto>> createClaim(@Valid ClaimRequestDto requestDto) {
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
}
