package com.insurancefraud.service;

import com.insurancefraud.dto.ClaimDocumentsResponseDto;
import com.insurancefraud.entity.ClaimDocument;
import com.insurancefraud.entity.enums.DocumentType;
import org.springframework.core.io.Resource;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Optional;

public interface ClaimDocumentService {

    ClaimDocumentsResponseDto uploadClaimDocument(
            Long claimId,
            MultipartFile file,
            DocumentType documentType
    );

    List<ClaimDocumentsResponseDto> getClaimDocumentsByClaimId(Long claimId);

    ClaimDocument getClaimDocumentById(Long documentId);
    void deleteClaimDocument(Long documentId);

    Resource downloadDocument(Long documentId);
}