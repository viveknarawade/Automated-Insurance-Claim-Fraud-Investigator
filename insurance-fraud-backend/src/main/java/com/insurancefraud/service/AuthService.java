package com.insurancefraud.service;

import com.insurancefraud.dto.*;
import jakarta.validation.Valid;

public interface AuthService {
    public void registerUser(RegisterRequestDto requestDto);
    public void verifyEmail(String token);
    public LoginResponseDto authenticateUser(@Valid LoginRequestDto loginDto);
    public void logout(LogoutRequestDto logoutDto);
    public void resendVerification(String email);
    public void delete(@Valid DeleteRequestDto deleteDto) ;

    public void forgotPassword(@Valid ForgotPasswordRequestDto requestDto);

    public void resetPassword(@Valid ResetPasswordRequestDto requestDto);
}
