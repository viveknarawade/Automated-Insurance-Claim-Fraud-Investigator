package com.insurancefraud.service.impl;

import com.insurancefraud.service.StorageService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StreamUtils;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.*;
import java.time.LocalDate;

@Service
@RequiredArgsConstructor
public class LocalStorageService implements StorageService {

    private final Path rootPath;

    @Override
    public String storeFile(InputStream inputStream,String storedFileName) throws IOException {
        LocalDate today = LocalDate.now();
        Path dateDirectory = rootPath.resolve(
                today.getYear()
                        + File.separator
                        + String.format("%02d", today.getMonthValue())
                        + File.separator
                        + String.format("%02d", today.getDayOfMonth())
        );

        Files.createDirectories(dateDirectory);
        Path filePath = dateDirectory.resolve(storedFileName);

        try (OutputStream outputStream = Files.newOutputStream(filePath, StandardOpenOption.CREATE_NEW)){
            StreamUtils.copy(inputStream, outputStream);
        }
        return rootPath.relativize(filePath).toString();
    }
}