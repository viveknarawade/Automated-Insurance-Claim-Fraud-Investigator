package com.insurancefraud.service;

public interface JwtService {

    public String generateEmailVerificationToken(String email);
    public String generateToken(String userId) ;
    public String generateRefreshToken(String userId);
    public String extractEmail(String token);
}
