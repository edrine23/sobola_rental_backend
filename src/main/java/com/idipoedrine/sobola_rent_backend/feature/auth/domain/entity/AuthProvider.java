package com.idipoedrine.sobola_rent_backend.feature.auth.domain.entity;


import com.idipoedrine.sobola_rent_backend.feature.auth.domain.enums.AuthProviderCode;
import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;


@Entity
@Table(name = "auth_providers")
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class AuthProvider {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Enumerated(EnumType.STRING)
    @Column(name = "code")
    private AuthProviderCode code;

    @Column(name = "enabled")
    private Boolean enabled;

    @Column(name = "deleted_at")
    private Instant deletedAt;


}
