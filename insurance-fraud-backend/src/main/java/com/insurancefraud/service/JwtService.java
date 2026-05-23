package com.insurancefraud.service;

import com.insurancefraud.entity.User;

public interface JwtService {

    String generateEmailVerificationToken(User user);

    String generateToken(User user);

    String generateRefreshToken(User user);

    Long extractUserId(String token);

    String generatePasswordResetToken(User user);
}