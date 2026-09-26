package com.idipoedrine.sobola_rent_backend.infrastructure.shared.dto;

import java.time.Instant;

public record ApiErrorResponse(
        Instant timeStamp,
        int status,
        String message
) {}



