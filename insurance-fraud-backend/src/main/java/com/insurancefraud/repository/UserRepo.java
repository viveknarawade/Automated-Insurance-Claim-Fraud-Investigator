package com.insurancefraud.repository;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import org.springframework.data.jpa.repository.JpaRepository;
import com.insurancefraud.entity.User;

import java.util.Optional;

public interface UserRepo extends JpaRepository<User,Long> {
    boolean existsByEmail(@NotBlank(message = "Email is required") @Email(message = "Invalid email format") String email);

    Optional<User> findByEmail(String email);
}
