package com.insurancefraud.repository;
import com.insurancefraud.entity.Tenant;
import jakarta.validation.constraints.NotBlank;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface TenantRepo extends JpaRepository<Tenant,Long> {

    Optional<Long> findIdByTenantCode(@NotBlank(message = "tenantCode is required") String tenantCode);

    Optional<Tenant>  findByTenantCode(@NotBlank(message = "tenantCode is required") String tenantCode);
}
