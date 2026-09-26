package com.idipoedrine.sobola_rent_backend.feature.auth.data.request;

public record LoginRequest(
        String email,
        String password
) {}

