package com.insurancefraud.service;


import com.insurancefraud.dto.ClaimRequestDto;
import com.insurancefraud.dto.ClaimResponseDto;
import jakarta.validation.Valid;

public interface ClaimService {
    ClaimResponseDto createClaim(@Valid ClaimRequestDto requestDto);
}
