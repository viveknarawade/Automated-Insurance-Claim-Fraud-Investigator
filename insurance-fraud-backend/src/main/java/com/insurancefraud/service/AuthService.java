package com.insurancefraud.service;

import com.insurancefraud.dto.RegisterRequestDto;

public interface AuthService {
    void registerUser(RegisterRequestDto requestDto);
    void verifyEmail(String token);
}
