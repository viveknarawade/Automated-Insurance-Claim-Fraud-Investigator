package com.insurancefraud.service.impl;

import com.insurancefraud.service.JwtService;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.time.Duration;
import java.util.Date;

@Slf4j
@Service
public class jwtServiceImpl implements JwtService {

    @Value("${jwt.secret}")
    private String secret;
    @Value("${jwt.access.expiration}")
    private Duration accessExpiration;
    @Value("${jwt.refresh.expiration}")
    private Duration refreshExpiration;

    private SecretKey getSignKey() {
        return Keys.hmacShaKeyFor(secret.getBytes());
    }

    @Override
    public String generateEmailVerificationToken(String email) {
        log.info("varification email :{}",email);
        return Jwts.builder()
                .subject(email)
                .claim("type", "EMAIL_VERIFICATION")
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis()+1000 * 60 * 30)) //30 Min
                .signWith(getSignKey())
                .compact();
    }

    @Override
    public String generateToken(String userId) {
        return "";
    }

    @Override
    public String generateRefreshToken(String userId) {
        return "";
    }

    //extract email from token
    @Override
    public String extractEmail(String token) {
        return Jwts.parser()
                .verifyWith(getSignKey())
                .build()
                .parseSignedClaims(token)
                .getPayload()
                .getSubject();
    }
}
