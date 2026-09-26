package com.idipoedrine.sobola_rent_backend.feature.auth.domain.repository;

import com.idipoedrine.sobola_rent_backend.feature.auth.domain.entity.Credential;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface CredentialRepository extends JpaRepository<Credential, UUID> {

    @Query("""
        SELECT c  from Credential c
        JOIN FETCH  c.user u
        JOIN FETCH  u.roles r
        LEFT JOIN FETCH r.permissions p
        LEFT JOIN FETCH c.authProvider a
        WHERE u.email =:email AND a.code =: code
    """)
    Optional<Credential> findCredentialByEmailAndAuthProviderCode(@Param("email") String email, @Param("code") String code);
}
