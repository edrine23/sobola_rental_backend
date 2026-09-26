package com.idipoedrine.sobola_rent_backend.feature.auth.application;


import com.idipoedrine.sobola_rent_backend.feature.auth.data.request.RegisterRequest;
import com.idipoedrine.sobola_rent_backend.feature.auth.data.response.RegisterResponse;
import com.idipoedrine.sobola_rent_backend.feature.auth.domain.entity.AuthProvider;
import com.idipoedrine.sobola_rent_backend.feature.auth.domain.entity.Credential;
import com.idipoedrine.sobola_rent_backend.feature.auth.domain.enums.AuthProviderCode;
import com.idipoedrine.sobola_rent_backend.feature.auth.domain.repository.AuthProviderRepository;
import com.idipoedrine.sobola_rent_backend.feature.auth.domain.repository.CredentialRepository;
import com.idipoedrine.sobola_rent_backend.feature.auth.mapper.RegisterMapper;
import com.idipoedrine.sobola_rent_backend.feature.user.domain.entity.Role;
import com.idipoedrine.sobola_rent_backend.feature.user.domain.entity.User;
import com.idipoedrine.sobola_rent_backend.feature.user.domain.enums.CredentialStatus;
import com.idipoedrine.sobola_rent_backend.feature.user.domain.enums.RoleCodes;
import com.idipoedrine.sobola_rent_backend.feature.user.domain.repository.RoleRepository;
import com.idipoedrine.sobola_rent_backend.feature.user.domain.repository.UserRepository;
import com.idipoedrine.sobola_rent_backend.infrastructure.shared.enums.SequenceType;
import com.idipoedrine.sobola_rent_backend.infrastructure.shared.exceptions.BusinessException;
import com.idipoedrine.sobola_rent_backend.infrastructure.shared.utility.SequenceGenerator;
import jakarta.transaction.Transactional;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.Period;
import java.util.Set;

@Slf4j
@AllArgsConstructor
@Service
public class RegisterUser {
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final AuthProviderRepository authProviderRepository;
    private final CredentialRepository credentialRepository;
    private final PasswordEncoder passwordEncoder;
    private final SequenceGenerator sequenceGenerator;
    private final RegisterMapper mapper;

    @Transactional
    public RegisterResponse execute(RegisterRequest request){
        log.info("Registration attempt for email: {}", request.email());

        if(userRepository.existsByEmail(request.email())){
            throw  new BusinessException("This email already exists");
        }

        //Todo : hash the nin and encrypt them for security. Later use the hash here to verify if it exists
        if(userRepository.existsByNationalIdentityNumber(request.nationalIdentityNumber())){
            throw  new BusinessException("This NIN already exists");
        }

        int age = Period.between(request.dateOfBirth(), LocalDate.now()).getYears();
        if (age < 18) {
            throw new BusinessException(
                    "You must be at least 18 years old to register on Sobola RMS. "
                            + "Ugandan law requires parties to tenancy agreements to be of legal age.");
        }

        String platformNumber = sequenceGenerator.generate(SequenceType.USER_NUMBER);
        User user = User.builder()
                        .platformNumber(platformNumber)
                        .firstName(request.firstName())
                        .lastName(request.lastName())
                        .dateOfBirth(request.dateOfBirth())
                        .phoneNumber(request.phoneNumber())
                        .email(request.email())
                        .nationality(request.nationality())
                        .nationalIdentityNumber(request.nationalIdentityNumber())
                        .build();

        // set the default role
        Role defaultUserRole = roleRepository
                                    .findByCode(RoleCodes.GUEST)
                                    .orElseThrow(
                                            () -> new BusinessException("Role Not found")
                                    );
        user.setRoles(Set.of(defaultUserRole));
        User savedUser = userRepository.save(user);

        //set the auth provider used
        AuthProvider defaultAuthProvider =  authProviderRepository
                                        .findByCode(AuthProviderCode.LOCAL)
                                        .orElseThrow(
                                                () -> new BusinessException("Auth Provider Not found")
                                        );

        // set up the user credential
        Credential credential = Credential.builder()
                                        .user(user)
                                        .authProvider(defaultAuthProvider)
                                        .passwordHash(passwordEncoder.encode(request.password()))
                                        .status(CredentialStatus.ACTIVE)
                                        .mustChangePassword(false)
                                        .build();
        credentialRepository.save(credential);

        //Todo: We shall add an event to publish notification

        log.info("User registered: {} | {}", savedUser.getPlatformNumber(), savedUser.getEmail());

        return mapper.toResponse("Account created successfully. Please log in.");
    }

}
