package com.idipoedrine.sobola_rent_backend.feature.auth.mapper;

import com.idipoedrine.sobola_rent_backend.feature.auth.data.response.RegisterResponse;
import org.springframework.stereotype.Component;

@Component
public class RegisterMapper {
    public RegisterResponse toResponse(String message){
        return new RegisterResponse(message);
    }
}
