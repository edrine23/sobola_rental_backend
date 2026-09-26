package com.idipoedrine.sobola_rent_backend.infrastructure.shared.exceptions;

public class BusinessException extends ApiException {
    public BusinessException(String message) {
        super(message);
    }
}
