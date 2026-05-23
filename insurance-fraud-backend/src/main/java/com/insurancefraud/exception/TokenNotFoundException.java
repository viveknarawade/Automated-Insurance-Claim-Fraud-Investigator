package com.insurancefraud.exception;


public class TokenNotFoundException extends RuntimeException{
    public TokenNotFoundException(String msg){
        super(msg);
    }
}