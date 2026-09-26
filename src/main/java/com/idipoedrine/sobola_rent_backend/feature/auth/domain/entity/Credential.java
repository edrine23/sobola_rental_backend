package com.idipoedrine.sobola_rent_backend.feature.auth.domain.entity;

import com.idipoedrine.sobola_rent_backend.feature.user.domain.entity.User;
import com.idipoedrine.sobola_rent_backend.feature.user.domain.enums.CredentialStatus;
import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "credentials")
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Builder
public class Credential {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne
    @JoinColumn(name = "auth_provider_id")
    private AuthProvider authProvider;

    @Column(name = "password_hash")
    private String passwordHash;

    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    private CredentialStatus status;

    @Column(name = "must_change_password")
    private Boolean mustChangePassword;

    @Column(name = "deleted_at")
    private Instant deletedAt;


}
