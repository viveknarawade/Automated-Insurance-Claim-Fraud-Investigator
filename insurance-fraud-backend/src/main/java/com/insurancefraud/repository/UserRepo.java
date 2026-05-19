package com.insurancefraud.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.insurancefraud.entity.User;

public interface UserRepo extends JpaRepository<User,Long> {
}
