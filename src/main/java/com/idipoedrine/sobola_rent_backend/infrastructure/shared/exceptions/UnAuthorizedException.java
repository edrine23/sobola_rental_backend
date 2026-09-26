package com.idipoedrine.sobola_rent_backend.infrastructure.shared.exceptions;

public class UnAuthorizedException extends ApiException {
    public UnAuthorizedException(String message) {
        super(message);
    }
}
