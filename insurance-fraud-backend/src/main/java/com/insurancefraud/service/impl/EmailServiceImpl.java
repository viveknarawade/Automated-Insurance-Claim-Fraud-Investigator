package com.insurancefraud.service.impl;

import com.insurancefraud.exception.EmailSendFailedException;
import com.insurancefraud.service.EmailService;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
@Slf4j
public class EmailServiceImpl implements EmailService {

    private final JavaMailSender mailSender;

    @Value("${spring.mail.username}")
    private String sender;

    @Async("emailTaskExecutor")
    @Override
    public void sendVerificationEmail(String email, String token) {

        try {
            String link =
                    "http://localhost:8081/api/v1/auth/verify-email?token=" + token;
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true);
            helper.setFrom(
                    "ClaimShield AI <" + sender + ">"
            );
            helper.setTo(email);
            helper.setSubject("Verify Your Account");
            String htmlContent = """
                    <div style="font-family: Arial, sans-serif; padding: 20px;">
                        <h2>Welcome to ClaimShield AI 🚀</h2>
                        <p>
                            Please verify your email by clicking the button below:
                        </p>
                        <a href="%s"
                           target="_blank"
                           style="
                               display:inline-block;
                               padding:10px 20px;
                               background-color:#4CAF50;
                               color:white;
                               text-decoration:none;
                               border-radius:5px;
                           ">
                           Verify Email
                        </a>
                        <p style="margin-top:20px;">
                            If you didn't request this, ignore this email.
                        </p>
                    </div>
                    """.formatted(link);
            helper.setText(htmlContent, true);
            mailSender.send(message);
            log.info("Verification email sent to {}", email);
        } catch (MessagingException e) {
            log.error(
                    "Failed to send verification email to {}",
                    email,
                    e
            );

            throw new EmailSendFailedException(
                    "Unable to send verification email"
            );
        }
    }

    @Async("emailTaskExecutor")
    @Override
    public void sendPasswordResetEmail(String email,String token) {
        try {
            String link = "http://localhost:5500/reset-password.html?token="+ token;
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true);
            helper.setFrom("ClaimShield AI <" + sender + ">");
            helper.setTo(email);
            helper.setSubject("Reset Your Password");
            String html = """
            <h2>Password Reset</h2>
            <p>Click below to reset password:</p>
            <a href="%s">
                Reset Password
            </a>
        """.formatted(link);
            helper.setText(html, true);
            mailSender.send(message);
            log.info("password reset email sent to {}", email);
        } catch (Exception e) {
            throw new EmailSendFailedException(
                    "Unable to send reset email"
            );
        }
    }
}