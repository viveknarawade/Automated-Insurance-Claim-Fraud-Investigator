package com.insurancefraud.service.impl;

import com.insurancefraud.common.exception.ResourceNotFoundException;
import com.insurancefraud.service.StorageService;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Service;
import org.springframework.util.StreamUtils;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.MalformedURLException;
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

    @Override
    public Resource downloadFile(String fileUrl) {
        try {
            Path filePath = rootPath.resolve(fileUrl).normalize();
            if (!Files.exists(filePath) || !Files.isRegularFile(filePath)) {
                throw new ResourceNotFoundException("File not found");
            }
            return new UrlResource(filePath.toUri());
        } catch (MalformedURLException e) {
            throw new ResourceNotFoundException("Invalid file path");
        }
    }


}