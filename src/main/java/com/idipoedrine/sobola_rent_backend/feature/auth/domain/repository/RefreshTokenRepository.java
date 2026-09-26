package com.idipoedrine.sobola_rent_backend.feature.auth.domain.repository;

import com.idipoedrine.sobola_rent_backend.feature.auth.domain.entity.RefreshToken;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface RefreshTokenRepository extends JpaRepository<RefreshToken, UUID> {
}
