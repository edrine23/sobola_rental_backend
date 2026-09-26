package com.idipoedrine.sobola_rent_backend.feature.user.domain.entity;

import com.idipoedrine.sobola_rent_backend.feature.user.domain.enums.RoleCodes;
import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

@Entity
@Table(name = "roles")
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Builder
public class Role {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Enumerated(EnumType.STRING)
    @Column(name = "code")
    private RoleCodes code;

    @Column(name = "description")
    private String description;

    @Column(name = "hierarchy_level")
    private Integer hierarchyLevel;

    @Column(name = "deleted_at")
    private Instant deleteAt;

    //relationships

    @ManyToMany
    @JoinTable(
            name = "role_permission",
            joinColumns = @JoinColumn(name = "role_id"),
            inverseJoinColumns = @JoinColumn(name = "permission_id")

    )
    private Set<Permission> permissions = new HashSet<>();
}
