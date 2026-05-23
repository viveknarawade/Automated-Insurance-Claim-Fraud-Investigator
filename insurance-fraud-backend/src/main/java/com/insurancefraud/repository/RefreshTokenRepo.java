package com.insurancefraud.repository;

import com.insurancefraud.entity.RefreshToken;
import com.insurancefraud.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;


import java.util.List;
import java.util.Optional;

public interface RefreshTokenRepo extends JpaRepository<RefreshToken,Long> {
    Optional<RefreshToken> findByToken(String refreshToken);
    List<RefreshToken> findByUser(User user);
}