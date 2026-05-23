package com.insurancefraud.dto;

import com.insurancefraud.entity.ClaimStatus;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class ClaimResponseDto {

    private Long claimId;
    private String claimNumber;
    private ClaimStatus claimStatus;
    private LocalDateTime createdAt;


}
