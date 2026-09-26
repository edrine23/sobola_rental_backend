package com.idipoedrine.sobola_rent_backend.infrastructure.shared.exceptions;

public class ApiException extends RuntimeException {
    public ApiException(String message) {
        super(message);
    }
}
