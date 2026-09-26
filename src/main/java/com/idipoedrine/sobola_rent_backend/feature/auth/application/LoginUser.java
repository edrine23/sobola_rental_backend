package com.idipoedrine.sobola_rent_backend.feature.auth.application;


import com.idipoedrine.sobola_rent_backend.feature.auth.data.request.LoginRequest;
import com.idipoedrine.sobola_rent_backend.feature.auth.data.response.LoginResponse;
import com.idipoedrine.sobola_rent_backend.feature.auth.domain.entity.RefreshToken;
import com.idipoedrine.sobola_rent_backend.feature.auth.domain.repository.RefreshTokenRepository;
import com.idipoedrine.sobola_rent_backend.feature.auth.helper.CustomUserDetails;
import com.idipoedrine.sobola_rent_backend.feature.auth.mapper.LoginMapper;
import com.idipoedrine.sobola_rent_backend.feature.user.domain.entity.User;
import com.idipoedrine.sobola_rent_backend.infrastructure.security.jwt.JwtService;
import com.idipoedrine.sobola_rent_backend.infrastructure.shared.exceptions.UnAuthorizedException;
import com.idipoedrine.sobola_rent_backend.infrastructure.shared.utility.TokenGenerator;
import com.idipoedrine.sobola_rent_backend.infrastructure.shared.utility.TokenHasher;
import jakarta.transaction.Transactional;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.*;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

@Slf4j
@AllArgsConstructor
@Service
public class LoginUser {
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final RefreshTokenRepository refreshTokenRepository;
    private final TokenGenerator tokenGenerator;
    private final TokenHasher tokenHasher;
    private final LoginMapper mapper;

    @Transactional
    public LoginResponse execute(LoginRequest request){
        log.info("Login attempt for email: {}", request.email());

        //Todo: later bruteforce defence mechanism
        Authentication authentication;
        try {
            authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            request.email(), request.password())
            );
        } catch (LockedException ex) {
            log.warn("Login attempt on locked account: {}", request.email());
            throw new UnAuthorizedException("Your account has been locked. Please contact support.");
        } catch (DisabledException ex) {
            log.warn("Login attempt on suspended/disabled account: {}", request.email());
            throw new UnAuthorizedException("Your account has been suspended. Please contact support.");
        } catch (BadCredentialsException ex) {
            //Todo record failed login attempts
            log.warn("Invalid credentials for: {}", request.email());
            throw new UnAuthorizedException("Invalid email or password");
        }

        CustomUserDetails customUserDetails = (CustomUserDetails) authentication.getPrincipal();
        if(customUserDetails == null || customUserDetails.getUser() ==null){
            throw new UnAuthorizedException("Invalid authentication state");
        }

        User user = customUserDetails.getUser();
        String accessToken = jwtService.generateAccessToken(user);
        String refreshToken = tokenGenerator.generate();

        RefreshToken refreshTokenObj = RefreshToken.builder()
                .user(user)
                .tokenHash(tokenHasher.hash(refreshToken))
                .revoked(false)
                .expiresAt(jwtService.computeRefreshExpiry())
                .build();
        refreshTokenRepository.save(refreshTokenObj);

        Boolean mustChangePassword = false;
        //Todo : Later we shall capture last login and more analytics

        log.info("User logged in successfully: {}", user.getId());
        return mapper.toResponse(accessToken, refreshToken, mustChangePassword);
    }
}
