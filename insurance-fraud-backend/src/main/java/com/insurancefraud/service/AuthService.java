package com.insurancefraud.service;

import com.insurancefraud.dto.*;
import jakarta.validation.Valid;

public interface AuthService {
    void registerUser(RegisterRequestDto requestDto);
    void verifyEmail(String token);
    LoginResponseDto authenticateUser(@Valid LoginRequestDto loginDto);
    void logout(LogoutRequestDto logoutDto);
    void resendVerification(String email);
    void delete(@Valid DeleteRequestDto deleteDto) ;
    void forgotPassword(@Valid ForgotPasswordRequestDto requestDto);
    void resetPassword(@Valid ResetPasswordRequestDto requestDto);
}
