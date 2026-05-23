package com.insurancefraud.repository;

import com.insurancefraud.entity.Claim;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ClaimRepo extends JpaRepository<Claim,Long> {
}
