package com.insurancefraud.dto;

import com.insurancefraud.entity.enums.DocumentStatus;
import com.insurancefraud.entity.enums.DocumentType;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

@Getter
@Setter
public class ClaimDocumentsResponseDto {

    private Long claimDocId;
    private DocumentType documentType;
    private String originalFileName;
    private String fileUrl;
    private String mimeType;
    private Long fileSize;
    private DocumentStatus documentStatus;
    private Instant createdAt;
}