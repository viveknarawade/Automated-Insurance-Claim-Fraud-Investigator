package com.insurancefraud.admin.dto;

import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class DashboardResponseDto {
    private Long totalClaims;
    private Long pendingClaims;
    private Long approvedClaims;
    private Long rejectedClaims;
    private Long suspectedFraudClaims;
    private Long underReviewClaims;

}
