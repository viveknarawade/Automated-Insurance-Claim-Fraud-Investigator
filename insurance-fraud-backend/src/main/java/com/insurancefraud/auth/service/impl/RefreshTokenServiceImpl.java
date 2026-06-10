package com.insurancefraud.auth.service.impl;

import com.insurancefraud.auth.dto.RefreshTokenRequestDto;
import com.insurancefraud.auth.dto.RefreshTokenResponseDto;
import com.insurancefraud.auth.repository.RefreshTokenRepo;
import com.insurancefraud.auth.service.RefreshTokenService;
import com.insurancefraud.common.exception.UnauthorizedException;
import com.insurancefraud.entity.RefreshToken;
import com.insurancefraud.entity.User;
import com.insurancefraud.service.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;

@Service
@RequiredArgsConstructor
@Transactional
public class RefreshTokenServiceImpl
        implements RefreshTokenService {

    private final RefreshTokenRepo refreshTokenRepo;

    private final JwtService jwtService;

    @Override
    public RefreshTokenResponseDto refreshToken(
            RefreshTokenRequestDto request
    ) {

        RefreshToken refreshToken =
                refreshTokenRepo
                        .findByToken(
                                request.getRefreshToken()
                        )
                        .orElseThrow(() ->
                                new UnauthorizedException(
                                        "Invalid refresh token"
                                )
                        );

        if (refreshToken.getExpiresAt()
                .isBefore(Instant.now())) {

            refreshTokenRepo.delete(refreshToken);

            throw new UnauthorizedException(
                    "Refresh token expired"
            );
        }

        User user = refreshToken.getUser();

        String newAccessToken =
                jwtService.generateToken(user);

        return new RefreshTokenResponseDto(
                newAccessToken
        );
    }
}