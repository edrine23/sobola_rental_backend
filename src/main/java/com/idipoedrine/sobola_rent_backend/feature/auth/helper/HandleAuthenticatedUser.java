package com.idipoedrine.sobola_rent_backend.feature.auth.helper;

import com.idipoedrine.sobola_rent_backend.feature.user.domain.entity.User;
import com.idipoedrine.sobola_rent_backend.infrastructure.shared.exceptions.UnAuthorizedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

public class HandleAuthenticatedUser {

    public User getAuthenticatedUser(){
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if(authentication == null || !authentication.isAuthenticated()){
            throw new UnAuthorizedException("User is not authenticated");
        }

        //get the user principal
        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();

        if(userDetails == null || userDetails.getUser() == null){
            throw new UnAuthorizedException("User is not authenticated");
        }

        return userDetails.getUser();
    }

}
