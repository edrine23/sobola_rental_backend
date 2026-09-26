package com.idipoedrine.sobola_rent_backend.feature.auth.helper;

import com.idipoedrine.sobola_rent_backend.feature.auth.domain.entity.Credential;
import com.idipoedrine.sobola_rent_backend.feature.auth.domain.enums.AuthProviderCode;
import com.idipoedrine.sobola_rent_backend.feature.auth.domain.repository.CredentialRepository;
import lombok.AllArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@AllArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {
    private final CredentialRepository credentialRepository;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        Credential credential = credentialRepository
                                    .findCredentialByEmailAndAuthProviderCode(email, AuthProviderCode.LOCAL.toString())
                                    .orElseThrow(
                                            () ->  new UsernameNotFoundException("User not found")
                                    );
        return new CustomUserDetails(credential.getUser(),credential.getPasswordHash());
    }
}
