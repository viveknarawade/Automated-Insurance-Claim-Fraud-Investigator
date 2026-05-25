package com.insurancefraud.controller;

import com.insurancefraud.dto.ClaimDocumentsResponseDto;
import com.insurancefraud.entity.enums.DocumentType;
import com.insurancefraud.payload.ApiResponse;
import com.insurancefraud.service.ClaimDocumentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.Instant;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/claims")
public class ClaimDocumentController {

    private final ClaimDocumentService claimDocumentService;

    @PostMapping("/{claimId}/documents")
    public ResponseEntity<ApiResponse<ClaimDocumentsResponseDto>>
    uploadClaimDocument(
            @PathVariable Long claimId,
            @RequestParam("file") MultipartFile file,
            @RequestParam("documentType") DocumentType documentType
    ) {

        ClaimDocumentsResponseDto data = claimDocumentService.uploadClaimDocument(claimId, file, documentType);

        ApiResponse<ClaimDocumentsResponseDto> response =
                new ApiResponse<>(
                        true,
                        "Document uploaded successfully",
                        201,
                        Instant.now(),
                        data
                );

        return ResponseEntity.ok(response);
    }
}