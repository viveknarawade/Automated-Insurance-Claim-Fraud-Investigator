package com.insurancefraud.repository;

import com.insurancefraud.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepo extends JpaRepository<User, Long> {

    boolean existsByEmail(String email);

    Optional<User> findByEmail(String email);

    @Query("""
        SELECT u FROM User u
        JOIN FETCH u.role
        JOIN FETCH u.tenant
        WHERE u.email = :email
    """)
    Optional<User> findByEmailWithRoleAndTenant(
            @Param("email") String email
    );

    @Query("""
        SELECT u FROM User u
        JOIN FETCH u.role
        JOIN FETCH u.tenant
        WHERE u.userId = :userId
    """)
    Optional<User> findByIdWithRoleAndTenant(
            @Param("userId") Long userId
    );
}