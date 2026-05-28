package com.insurancefraud.investigator.service;

import com.insurancefraud.investigator.dto.InvestigatorClaimResponseDto;
import com.insurancefraud.investigator.dto.InvestigatorClaimReviewRequestDto;
import com.insurancefraud.investigator.dto.InvestigatorClaimReviewResponseDto;

import java.util.List;

public interface InvestigatorClaimService {
    List<InvestigatorClaimResponseDto> getAssignedClaimsForInvestigator();

    InvestigatorClaimReviewResponseDto reviewClaimById(Long claimId, InvestigatorClaimReviewRequestDto requestDto);
}
