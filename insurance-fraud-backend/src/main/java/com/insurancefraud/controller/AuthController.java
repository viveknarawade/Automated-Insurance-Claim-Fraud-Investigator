package com.insurancefraud.controller;

import com.insurancefraud.dto.RegisterRequestDto;
import com.insurancefraud.exception.ApiError;
import com.insurancefraud.payload.ApiResponse;
import com.insurancefraud.service.AuthService;
import jakarta.validation.Valid;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/auth")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    ResponseEntity<ApiResponse<Void>> register(@Valid @RequestBody RegisterRequestDto requestDto){
        authService.registerUser(requestDto);
        ApiResponse<Void> response = new ApiResponse<>(
                true,
                "Registration successful. Please verify your email.",
                HttpStatus.CREATED.value(),
                Instant.now(),
                null
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/verify-email")
    public ResponseEntity<ApiResponse<String>> verifyEmail(@RequestParam String token) {
        authService.verifyEmail(token);
        ApiResponse<String> response = new ApiResponse<>(
                true,
                "Email verified successfully",
                200,
                Instant.now(),
                null
        );
        return ResponseEntity.ok(response);
    }

}
