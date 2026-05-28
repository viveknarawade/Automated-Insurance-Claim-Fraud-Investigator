package com.insurancefraud.claim.dto;

import com.insurancefraud.enums.ClaimStatus;
import com.insurancefraud.enums.ClaimType;
import com.insurancefraud.enums.FraudStatus;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDateTime;

@Getter
@Setter
public class ClaimDetailResponseDto {

    private Long claimId;

    private String claimNumber;

    private ClaimType claimType;

    private BigDecimal claimAmount;

    private ClaimStatus claimStatus;

    private FraudStatus fraudStatus;

    private BigDecimal fraudScore;

    private String description;

    private LocalDateTime incidentDate;

    private String incidentAddress;

    private String incidentCity;

    private String incidentState;

    private String reviewNotes;

    private Instant createdAt;

    private Instant updatedAt;
}