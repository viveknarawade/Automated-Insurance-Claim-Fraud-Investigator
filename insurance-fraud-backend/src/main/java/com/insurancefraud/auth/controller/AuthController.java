package com.insurancefraud.auth.controller;

import com.insurancefraud.auth.dto.*;
import com.insurancefraud.common.payload.ApiResponse;
import com.insurancefraud.auth.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import jakarta.validation.Valid;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;

@Slf4j
@RestController
@RequiredArgsConstructor
@Tag(name = "Authentication APIs")
@RequestMapping("/api/v1/auth")
public class AuthController {

    private final AuthService authService;

    @Operation(summary = "Register user")
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

    @Operation(summary = "send email verification")
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

    @Operation(summary = "Login user")
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<LoginResponseDto>> login(@Valid @RequestBody LoginRequestDto loginDto) {

        LoginResponseDto data = authService.authenticateUser(loginDto);

        ApiResponse<LoginResponseDto> response = new ApiResponse<>(
                true,
                "Login successful",
                200,
                Instant.now(),
                data
        );

        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Logout user")
    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>>  logout(@Valid @RequestBody LogoutRequestDto logoutDto){

        authService.logout(logoutDto);
        ApiResponse<Void>  response = new ApiResponse<>(
                true,
                "Logged out successfully",
                200,
                Instant.now(),
                null
        );

        return  ResponseEntity.ok(response);
    }

    @Operation(summary = "Delete user account ")
    @PostMapping("/delete-account")
    public ResponseEntity<ApiResponse<Void>> deleteAccount(@Valid @RequestBody DeleteRequestDto deleteDto){

        log.info("DELETE ACCOUNT API HIT");
        authService.delete(deleteDto);
        log.info("ACCOUNT DELETED");

        ApiResponse<Void> response = new ApiResponse<>(
                true,
                "Account deleted successfully",
                200,
                Instant.now(),
                null
        );
        return  ResponseEntity.ok(response);
    }

    @Operation(summary = "send email reverification")
    @PostMapping("/resend-verification")
    public ResponseEntity<ApiResponse<String>> resend(@Valid @RequestBody ResendVerificationRequest request) {

        authService.resendVerification(request.getEmail());

        return ResponseEntity.ok(
                new ApiResponse<>(true, "Verification email sent", 200, Instant.now(), null)
        );
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<ApiResponse<Void>> forgotPassword(
            @Valid
            @RequestBody
            ForgotPasswordRequestDto requestDto
    ) {
        authService.forgotPassword(requestDto);
        ApiResponse<Void> response =
                new ApiResponse<>(
                        true,
                        "If email exists, reset link sent",
                        200,
                        Instant.now(),
                        null
                );
        return ResponseEntity.ok(response);
    }

    @PostMapping("/reset-password")
    public ResponseEntity<ApiResponse<Void>>
    resetPassword(
            @Valid
            @RequestBody
            ResetPasswordRequestDto requestDto
    ) {
        authService.resetPassword(requestDto);
        return ResponseEntity.ok(
                new ApiResponse<>(
                        true,
                        "Password reset successful",
                        200,
                        Instant.now(),
                        null
                )
        );
    }

}
