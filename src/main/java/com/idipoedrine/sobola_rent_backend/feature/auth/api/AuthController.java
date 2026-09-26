package com.idipoedrine.sobola_rent_backend.feature.auth.api;

import com.idipoedrine.sobola_rent_backend.feature.auth.application.LoginUser;
import com.idipoedrine.sobola_rent_backend.feature.auth.application.RegisterUser;
import com.idipoedrine.sobola_rent_backend.feature.auth.data.request.LoginRequest;
import com.idipoedrine.sobola_rent_backend.feature.auth.data.request.RegisterRequest;
import com.idipoedrine.sobola_rent_backend.feature.auth.data.response.LoginResponse;
import com.idipoedrine.sobola_rent_backend.feature.auth.data.response.RegisterResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
@AllArgsConstructor
@Tag(name = "Authentication", description = "Register, login, refresh and logout")
public class AuthController {
    private final LoginUser loginUser;
    private final RegisterUser registerUser;

    @Operation(summary = "Register a user")
    @PostMapping("/register")
    public ResponseEntity<RegisterResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(registerUser.execute(request));
    }

    @Operation(summary = "Login in a user")
    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        //TODO: refresh token to be set as http only
        return ResponseEntity.ok(loginUser.execute(request));
    }

}
