package com.insurancefraud.service.impl;

import com.insurancefraud.dto.ClaimDocumentsResponseDto;
import com.insurancefraud.entity.*;
import com.insurancefraud.entity.enums.*;
import com.insurancefraud.exception.*;
import com.insurancefraud.repository.*;
import com.insurancefraud.service.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class ClaimDocumentServiceImpl
        implements ClaimDocumentService {

    private final CurrentUserService currentUserService;
    private final StorageService storageService;
    private final UserRepo userRepo;
    private final ClaimRepo claimRepo;
    private final ClaimDocumentRepo claimDocumentRepo;
    private final ModelMapper mapper;

    @Transactional
    @Override
    public ClaimDocumentsResponseDto uploadClaimDocument(
            Long claimId,
            MultipartFile file,
            DocumentType documentType
    ) {

        validateFile(file);
        User currentUser = currentUserService.getCurrentActiveUser();
        User user = userRepo.findById(currentUser.getUserId())
                .orElseThrow(() ->
                        new UserNotFoundException(
                                "User not found"
                        )
                );

        Claim claim = claimRepo.findByClaimIdAndIsDeletedFalse(claimId)
                .orElseThrow(() -> new ResourceNotFoundException(
                                        "Claim not found"
                                )
                        );

        if (!claim.getUser().getUserId().equals(user.getUserId())) {
            throw new UnauthorizedException("You cannot upload documents to this claim");
        }

        String originalFileName = file.getOriginalFilename();

        if (originalFileName == null || originalFileName.isBlank()) {
            throw new InvalidFileException("Invalid file name");
        }

        String extension = getFileExtension(originalFileName);
        String storedFileName = UUID.randomUUID() + (extension.isBlank() ? "" : "." + extension);
        String storagePath;
        try (InputStream inputStream = file.getInputStream()){
            storagePath = storageService.storeFile(inputStream, storedFileName);
        } catch (IOException e) {
            log.error("File upload failed: {}", e.getMessage());
            throw new FileStorageException("Failed to store file", e);
        }

        ClaimDocument claimDocument = new ClaimDocument();
        claimDocument.setTenant(user.getTenant());
        claimDocument.setClaim(claim);
        claimDocument.setUploadedBy(user);
        claimDocument.setDocumentType(documentType);
        claimDocument.setFileName(storedFileName);
        claimDocument.setOriginalFileName(originalFileName);
        claimDocument.setFileUrl(storagePath);
        claimDocument.setStorageProvider(StorageProvider.LOCAL);
        claimDocument.setMimeType(file.getContentType());
        claimDocument.setFileSize(file.getSize());
        claimDocument.setDocumentStatus(DocumentStatus.ACTIVE);
        claimDocument = claimDocumentRepo.save(claimDocument);
        log.info("Document uploaded successfully for claim {}", claim.getClaimNumber());

        return mapper.map(
                claimDocument,
                ClaimDocumentsResponseDto.class
        );
    }

    private void validateFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new EmptyFileException("File is empty");
        }
        String mimeType = file.getContentType();

        if (mimeType == null || !SupportedDocumentType.isValidMimeType(mimeType)) {
            throw new InvalidMimeTypeException("Unsupported file type");
        }

        long maxFileSize = 10 * 1024 * 1024;
        if (file.getSize() > maxFileSize) {
            throw new InvalidFileException("File size exceeds 10MB");
        }
    }

    private String getFileExtension(String fileName) {
        int lastDot = fileName.lastIndexOf('.');
        return lastDot == -1 ? "" : fileName.substring(lastDot + 1);
    }
}