package com.insurancefraud.service;

import org.springframework.core.io.Resource;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;

public interface StorageService {

    String storeFile(InputStream inputStream,String storedFileName) throws IOException;
    Resource downloadFile(String fileUrl);
}