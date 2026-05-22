package com.insurancefraud.service.impl;

import com.insurancefraud.dto.RegisterRequestDto;
import com.insurancefraud.entity.*;
import com.insurancefraud.exception.EmailAlreadyVerifiedException;
import com.insurancefraud.exception.RoleNotFoundException;
import com.insurancefraud.exception.TenantNotFoundException;
import com.insurancefraud.exception.UserAlreadyExistsException;
import com.insurancefraud.repository.*;
import com.insurancefraud.service.AuthService;
import com.insurancefraud.service.EmailService;
import com.insurancefraud.service.JwtService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.modelmapper.ModelMapper;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;


@Slf4j
@Service
@Transactional
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserRepo userRepo;
    private final TenantRepo tenantRepo;
    private final RoleRepo roleRepo;
    private final ModelMapper mapper;
    private final PasswordEncoder encoder;
    private final JwtService jwtService;
    private final EmailService emailService;

    // Register User and send Verification email
    @Override
    public void registerUser(RegisterRequestDto requestDto) {

        if (userRepo.existsByEmail(requestDto.getEmail())) {
            throw new UserAlreadyExistsException(
                    "A user with email " + requestDto.getEmail() + " already exists."
            );
        }
        Tenant tenant = tenantRepo.findByTenantCode(requestDto.getTenantCode())
                .orElseThrow(() ->
                        new TenantNotFoundException(
                                "No tenant exists with code: " + requestDto.getTenantCode()
                        )
                );
        Role userRole = roleRepo.findByRoleCode(RoleCode.USER)
                .orElseThrow(() ->
                        new RoleNotFoundException("Default USER role not found.")
                );

        User newUser = mapper.map(requestDto, User.class);
        newUser.setPasswordHash(
                encoder.encode(requestDto.getPassword())
        );

        newUser.setStatus(UserStatus.PENDING);
        newUser.setTenant(tenant);
        newUser.setRole(userRole);
        newUser.setEmailVerifiedAt(null);
        User savedUser = userRepo.save(newUser);
        log.info("User registered email {} ",savedUser.getEmail());

        String token = jwtService.generateEmailVerificationToken(savedUser.getEmail());
        emailService.sendVerificationEmail(savedUser.getEmail(), token);


    }

    // Verify User Email
    @Override
    public void verifyEmail(String token) {
        String email = jwtService.extractEmail(token);
        User user = userRepo.findByEmail(email).orElseThrow(()->
                new UsernameNotFoundException("User not found..."));

        if(user.getEmailVerifiedAt() !=null){
            throw  new EmailAlreadyVerifiedException("Already Verified");
        }
        user.setEmailVerifiedAt(Instant.now());
        user.setStatus(UserStatus.ACTIVE);
        userRepo.save(user);
    }
}
