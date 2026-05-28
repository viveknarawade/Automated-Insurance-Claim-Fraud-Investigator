package com.insurancefraud.investigator.controller;

import com.insurancefraud.common.payload.ApiResponse;
import com.insurancefraud.investigator.dto.InvestigatorClaimReviewRequestDto;
import com.insurancefraud.investigator.dto.InvestigatorClaimReviewResponseDto;
import com.insurancefraud.investigator.dto.InvestigatorClaimResponseDto;
import com.insurancefraud.investigator.service.InvestigatorClaimService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.List;

@RequestMapping("/api/v1/investigator")
@RestController
public class InvestigatorClaimController {

    private final InvestigatorClaimService investigatorClaimService;

    public InvestigatorClaimController(InvestigatorClaimService investigatorClaimService) {
        this.investigatorClaimService = investigatorClaimService;
    }

    @GetMapping("/claims")
    public ResponseEntity<ApiResponse<List<InvestigatorClaimResponseDto>>> getAssignedClaims() {
        List<InvestigatorClaimResponseDto> data = investigatorClaimService.getAssignedClaimsForInvestigator();

        ApiResponse<List<InvestigatorClaimResponseDto>> response =
                new ApiResponse<>(
                        true,
                        "Assigned claims retrieved successfully",
                        200,
                        Instant.now(),
                        data
                );
        return ResponseEntity.ok(response);
    }


    @PatchMapping("/claims/{claimId}/review")
    public ResponseEntity<ApiResponse<InvestigatorClaimReviewResponseDto>> reviewClaim(
            @PathVariable Long claimId,
            @Valid
            @RequestBody InvestigatorClaimReviewRequestDto requestDto
    ) {
        InvestigatorClaimReviewResponseDto reviewResponseDto =
                investigatorClaimService.reviewClaimById(
                        claimId,
                        requestDto
                );
        ApiResponse<InvestigatorClaimReviewResponseDto> response =
                new ApiResponse<>(
                        true,
                        "Claim reviewed successfully",
                        200,
                        Instant.now(),
                        reviewResponseDto
                );

        return ResponseEntity.ok(response);
    }
}
