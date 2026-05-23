package com.insurancefraud.exception;

public class TokenAlreadyRevokedException extends RuntimeException {
    public TokenAlreadyRevokedException(String message) {
        super(message);
    }
}