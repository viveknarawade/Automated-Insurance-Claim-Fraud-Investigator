package com.insurancefraud.service;

import java.io.IOException;
import java.io.InputStream;

public interface StorageService {

    String storeFile(InputStream inputStream,String storedFileName) throws IOException;
}