package com.insurancefraud.service;

import jakarta.mail.MessagingException;

public interface EmailService {
    public void sendVerificationEmail(String email,String token);
}
