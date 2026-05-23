package com.insurancefraud.exception;


public class EmailNotVerifiedException extends  RuntimeException{

    public EmailNotVerifiedException(String msg){
        super(msg);
    }
}