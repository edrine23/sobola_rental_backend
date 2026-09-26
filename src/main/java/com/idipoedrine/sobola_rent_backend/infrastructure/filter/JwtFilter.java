package com.idipoedrine.sobola_rent_backend.infrastructure.filter;


import com.idipoedrine.sobola_rent_backend.feature.auth.domain.entity.Credential;
import com.idipoedrine.sobola_rent_backend.feature.auth.domain.enums.AuthProviderCode;
import com.idipoedrine.sobola_rent_backend.feature.auth.domain.repository.CredentialRepository;
import com.idipoedrine.sobola_rent_backend.feature.auth.helper.CustomUserDetails;
import com.idipoedrine.sobola_rent_backend.feature.user.domain.entity.User;
import com.idipoedrine.sobola_rent_backend.infrastructure.security.jwt.Jwt;
import com.idipoedrine.sobola_rent_backend.infrastructure.security.jwt.JwtService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Slf4j
@AllArgsConstructor
@Component
public class JwtFilter extends OncePerRequestFilter {
    private final JwtService jwtService;
    private final CredentialRepository credentialRepository;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        //get the request path
        String path = request.getRequestURI();

        String authHeader = request.getHeader("Authorization");
        if( authHeader== null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request,response);
            return;
        }

        //get the raw token from the header
        String token = authHeader.substring(7);

        //check if the token is valid
        Jwt jwt = jwtService.generateJwtFromAccessToken(token).orElse(null);
        if( jwt == null){
            log.warn("Invalid JWT token on {} {}", request.getMethod(), path);
            filterChain.doFilter(request, response);
            return;
        }
        if (jwt.isExpired()) {
            log.warn("Expired JWT token on {} {}", request.getMethod(), path);
            filterChain.doFilter(request, response);
            return;
        }

        //get the context holder check if it is not set
        if (SecurityContextHolder.getContext().getAuthentication() != null) {
            filterChain.doFilter(request, response);
            return;
        }

        //get the user email
        String email = jwt.getUserEmail();
        try{
            Credential credential = credentialRepository
                                        .findCredentialByEmailAndAuthProviderCode(email, AuthProviderCode.LOCAL.toString())
                                        .orElseThrow( () ->  new UsernameNotFoundException("Credential not found"));

            User user = credential.getUser();
            //Todo: account user check if locked,suspended,or inactive and return needed message

            CustomUserDetails userDetails = new CustomUserDetails(user,null);

            //create a username password authentication token
            UsernamePasswordAuthenticationToken authenticationToken = new UsernamePasswordAuthenticationToken(
                    userDetails, null, userDetails.getAuthorities()
            );
            authenticationToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

            //set the security contex with authentication token
            SecurityContextHolder.getContext().setAuthentication(authenticationToken);


            log.debug("Authenticated user: {} | {} {}", email, request.getMethod(), path);

        }catch (Exception ex){
            log.error("Failed to authenticate user {}: {}", email, ex.getMessage());
        }

        filterChain.doFilter(request, response);
    }
}
