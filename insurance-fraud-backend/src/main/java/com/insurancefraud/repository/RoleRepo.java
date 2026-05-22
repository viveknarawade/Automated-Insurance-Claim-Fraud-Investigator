package com.insurancefraud.repository;

import com.insurancefraud.entity.Role;
import com.insurancefraud.entity.RoleCode;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RoleRepo extends JpaRepository<Role,Long> {
    Optional<Role> findByRoleCode(RoleCode roleCode);
}
