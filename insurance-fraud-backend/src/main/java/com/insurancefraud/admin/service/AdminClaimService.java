package com.insurancefraud.admin.service;

import com.insurancefraud.admin.dto.InvestigatorsWorkloadResDto;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;

import java.util.List;

public interface AdminClaimService {
    void assignInvestigatorToClaim(@Valid Long claimId, @NotNull(message = "Investigator ID cannot be null") Long investigatorId);

    List<InvestigatorsWorkloadResDto> getInvestigatorsWorkload();
}
