package com.idipoedrine.sobola_rent_backend.infrastructure.security.jwt;

import io.jsonwebtoken.security.Keys;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

import javax.crypto.SecretKey;


@Configuration
@ConfigurationProperties(prefix = "jwt")
@Data
public class JwtProperties {
    private int accessTokenExpiration;
    private int refreshTokenExpiration;
    private String secrete;

    public SecretKey getSecreteKey(){
        return Keys.hmacShaKeyFor(secrete.getBytes());
    }
}
