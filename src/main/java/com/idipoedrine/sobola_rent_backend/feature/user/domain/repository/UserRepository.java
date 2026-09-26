package com.idipoedrine.sobola_rent_backend.feature.user.domain.repository;

import com.idipoedrine.sobola_rent_backend.feature.user.domain.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface UserRepository extends JpaRepository<User, UUID> {
    Boolean existsByEmail(String email);
    Boolean existsByNationalIdentityNumber(String nationalIdentityNumber);
}
