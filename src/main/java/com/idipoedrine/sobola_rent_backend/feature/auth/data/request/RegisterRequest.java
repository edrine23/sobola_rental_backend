package com.idipoedrine.sobola_rent_backend.feature.auth.data.request;

import java.time.LocalDate;

public record RegisterRequest(
        String firstName,
        String lastName,
        LocalDate dateOfBirth,
        String phoneNumber,
        String email,
        String nationality,
        String nationalIdentityNumber,
        String password
) {}
