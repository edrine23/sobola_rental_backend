package com.idipoedrine.sobola_rent_backend.feature.auth.mapper;

import com.idipoedrine.sobola_rent_backend.feature.auth.data.response.LoginResponse;
import org.springframework.stereotype.Component;

@Component
public class LoginMapper {
    public LoginResponse toResponse(String accessToken, String refreshToken, Boolean mustChangePassword){
        return new LoginResponse(accessToken, refreshToken, mustChangePassword);
    }

}
