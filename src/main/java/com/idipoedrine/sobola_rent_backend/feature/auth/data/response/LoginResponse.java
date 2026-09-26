package com.idipoedrine.sobola_rent_backend.feature.auth.data.response;

public record LoginResponse (
        String accessToken,
        String refreshToken,
        Boolean mustChangePassword

){}
