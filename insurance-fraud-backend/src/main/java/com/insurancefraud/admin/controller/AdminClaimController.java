package com.insurancefraud.admin.controller;

import com.insurancefraud.admin.dto.AssignInvestigatorRequestDto;
import com.insurancefraud.admin.dto.InvestigatorsWorkloadResDto;
import com.insurancefraud.admin.service.AdminClaimService;
import com.insurancefraud.common.payload.ApiResponse;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.List;

@RequestMapping("/api/v1/admin")
@RestController
public class AdminClaimController {

    private final AdminClaimService adminClaimService;

    public AdminClaimController(AdminClaimService adminClaimService) {
        this.adminClaimService = adminClaimService;
    }

    @PatchMapping("/claims/{claimId}/assign-investigator")
    public ResponseEntity<ApiResponse<Void>>
    assignInvestigatorToClaim(
            @PathVariable Long claimId,
            @Valid @RequestBody AssignInvestigatorRequestDto requestDto
    ) {
        adminClaimService.assignInvestigatorToClaim(
                claimId,
                requestDto.getInvestigatorId()
        );

        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Claim assigned for investigation",
                        200,
                        Instant.now(),
                        null
                )
        );
    }


    @GetMapping("/investigators/workload")
    public ResponseEntity<ApiResponse<List<InvestigatorsWorkloadResDto>>> getInvestigatorsWorkload() {

        List<InvestigatorsWorkloadResDto> workloadResDtoList =
                adminClaimService.getInvestigatorsWorkload();

        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Investigator workload retrieved successfully",
                        200,
                        Instant.now(),
                        workloadResDtoList
                )
        );
    }
}
