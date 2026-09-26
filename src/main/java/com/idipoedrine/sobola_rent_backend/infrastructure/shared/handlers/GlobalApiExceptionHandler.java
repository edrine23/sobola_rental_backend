package com.idipoedrine.sobola_rent_backend.infrastructure.shared.handlers;

import com.idipoedrine.sobola_rent_backend.infrastructure.shared.dto.ApiErrorResponse;
import com.idipoedrine.sobola_rent_backend.infrastructure.shared.exceptions.BusinessException;
import com.idipoedrine.sobola_rent_backend.infrastructure.shared.exceptions.UnAuthorizedException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.Instant;

@RestControllerAdvice
@Slf4j
public class GlobalApiExceptionHandler {

    // General BusinessException
    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ApiErrorResponse> handleBusinessException(
            BusinessException ex) {
        log.warn("Business rule violation: {}", ex.getMessage());
        return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .body(new ApiErrorResponse(
                        Instant.now(),
                        400,
                        ex.getMessage()
                ));
    }

    // handle An authorized
    @ExceptionHandler(UnAuthorizedException.class)
    public ResponseEntity<ApiErrorResponse> handleUnauthorizedException(
            UnAuthorizedException ex) {
        log.warn("Unauthorized for the resource: {}", ex.getMessage());
        return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .body(new ApiErrorResponse(
                        Instant.now(),
                        401,
                        ex.getMessage()
                ));
    }




}
