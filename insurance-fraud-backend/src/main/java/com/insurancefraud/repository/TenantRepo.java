package com.insurancefraud.repository;
import com.insurancefraud.entity.Tenant;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TenantRepo extends JpaRepository<Tenant,Long> {
}
