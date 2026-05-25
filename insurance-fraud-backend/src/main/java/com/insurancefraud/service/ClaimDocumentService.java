package com.insurancefraud.service;

import com.insurancefraud.dto.ClaimDocumentsResponseDto;
import com.insurancefraud.entity.enums.DocumentType;
import org.springframework.web.multipart.MultipartFile;

public interface ClaimDocumentService {

    ClaimDocumentsResponseDto uploadClaimDocument(
            Long claimId,
            MultipartFile file,
            DocumentType documentType
    );
}