package com.insurancefraud.exception;

public class AccountDeletedException extends RuntimeException{
    public AccountDeletedException(String msg){
        super(msg);
    }
}