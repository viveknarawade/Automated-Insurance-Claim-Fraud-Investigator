package com.insurancefraud.admin.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
@AllArgsConstructor
public class InvestigatorsWorkloadResDto {
       private Long investigatorId;
       private String fullName;
       private Long activeClaims;

}
