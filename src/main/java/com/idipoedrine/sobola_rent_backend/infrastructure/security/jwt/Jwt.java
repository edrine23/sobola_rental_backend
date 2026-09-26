package com.idipoedrine.sobola_rent_backend.infrastructure.security.jwt;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import lombok.AllArgsConstructor;

import javax.crypto.SecretKey;
import java.util.Date;

@AllArgsConstructor
public class Jwt {
    private final Claims claims;
    private final SecretKey secretKey;

    public Boolean isExpired(){
        try {
            return claims.getExpiration().before(new Date());
        }catch (JwtException e){
            return true;
        }
    }


    public String generateToken(){
        return Jwts.builder().claims(claims).signWith(secretKey).compact();
    }

    public String getUserEmail(){
        return claims.get("email",String.class);
    }

}
