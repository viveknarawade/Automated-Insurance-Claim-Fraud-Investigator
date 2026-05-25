package com.insurancefraud.repository;

import com.insurancefraud.entity.ClaimDocument;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ClaimDocumentRepo extends JpaRepository<ClaimDocument,Long>  {
}
