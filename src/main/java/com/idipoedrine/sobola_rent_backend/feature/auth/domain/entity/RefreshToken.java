package com.idipoedrine.sobola_rent_backend.feature.auth.domain.entity;

import com.idipoedrine.sobola_rent_backend.feature.user.domain.entity.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;
@Entity
@Table(name = "refresh_tokens")
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Builder
public class RefreshToken {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @Column(name = "token_hash")
    private String tokenHash;

    @Column(nullable = false)
    private Boolean revoked = false;

    @Column(name = "expires_at")
    private Instant expiresAt;

}


