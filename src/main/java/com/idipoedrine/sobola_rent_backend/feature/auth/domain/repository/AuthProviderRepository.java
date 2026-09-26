package com.idipoedrine.sobola_rent_backend.feature.auth.domain.repository;

import com.idipoedrine.sobola_rent_backend.feature.auth.domain.entity.AuthProvider;
import com.idipoedrine.sobola_rent_backend.feature.auth.domain.enums.AuthProviderCode;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface AuthProviderRepository extends JpaRepository<AuthProvider, UUID> {

    Optional<AuthProvider> findByCode(AuthProviderCode code);
}
