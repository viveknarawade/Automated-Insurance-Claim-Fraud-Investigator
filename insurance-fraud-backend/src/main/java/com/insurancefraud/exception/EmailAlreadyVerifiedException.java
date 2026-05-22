package com.insurancefraud.exception;

import lombok.extern.slf4j.Slf4j;

@Slf4j
public class EmailAlreadyVerifiedException extends  RuntimeException{
    public EmailAlreadyVerifiedException(String msg){
        super(msg);
        log.info("EmailAlreadyVerifiedException: {}",msg);

    }
}
