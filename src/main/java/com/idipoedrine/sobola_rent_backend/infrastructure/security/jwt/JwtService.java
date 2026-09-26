package com.idipoedrine.sobola_rent_backend.infrastructure.security.jwt;

import com.idipoedrine.sobola_rent_backend.feature.user.domain.entity.User;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.LocalDateTime;
import java.util.Date;
import java.util.Optional;

@Service
@AllArgsConstructor
public class JwtService {
    private final JwtProperties jwtProperties;


    public String generateAccessToken(User user){
        return generateJwt(user, jwtProperties.getAccessTokenExpiration())
                .generateToken();
    }

    public Optional<Jwt> generateJwtFromAccessToken(String token){
        try {
            Claims claims = generateClaimsFromToken(token);
            return Optional.of(new Jwt(claims, jwtProperties.getSecreteKey()));
        }catch (JwtException e){
            return Optional.empty();
        }
    }
    // computing the refresh token expiration
    public Instant computeRefreshExpiry() {
        return Instant.now().plusSeconds(jwtProperties.getRefreshTokenExpiration());
    }


    //=== private helper
    private Jwt generateJwt(User user, long tokenExpiration){
        Claims claims = Jwts.claims()
                            .subject(user.getId().toString())
                            .add("email",user.getEmail())
                            .issuedAt(new Date())
                            .expiration(new Date(System.currentTimeMillis()+ 1000L * tokenExpiration))
                            .build();

        return new Jwt(claims, jwtProperties.getSecreteKey());
    }

    private Claims generateClaimsFromToken(String token){

        return Jwts.parser()
                .verifyWith(jwtProperties.getSecreteKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }
}
