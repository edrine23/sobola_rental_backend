package com.idipoedrine.sobola_rent_backend.feature.auth.helper;

import com.idipoedrine.sobola_rent_backend.feature.user.domain.entity.User;
import lombok.AllArgsConstructor;
import lombok.Getter;
import org.jspecify.annotations.Nullable;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.HashSet;

import java.util.Set;

@AllArgsConstructor
public class CustomUserDetails implements UserDetails {

    @Getter
    private final User user;
    private final String passwordHash;


    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        Set<SimpleGrantedAuthority> authorities = new HashSet<SimpleGrantedAuthority>();

        //setting the roles
        user.getRoles().forEach(
                role -> authorities.add(new SimpleGrantedAuthority(role.getCode().toString()))
        );
        //setting the permissions under each role
        user.getRoles().forEach(
                role -> role.getPermissions().forEach(
                        permission -> authorities.add(new SimpleGrantedAuthority(permission.getCode()))
                )
        );

        return authorities;
    }

    @Override
    public @Nullable String getPassword() {
        return passwordHash;
    }

    @Override
    public String getUsername() {
        return user.getEmail();
    }

}
