package com.oceanview.dao;

import com.oceanview.model.BaseUser;

/**
 * Strategy Pattern Interface for Authentication
 * This allows different authentication strategies for Staff and Guests
 * Design Pattern: STRATEGY PATTERN
 */
public interface AuthenticationStrategy {
    /**
     * Authenticate a user with username and password
     * @param username User's username
     * @param password User's plain password
     * @return BaseUser object if authentication succeeds, null otherwise
     */
    BaseUser authenticate(String username, String password);
    
    /**
     * Get the type of authentication this strategy handles
     * @return Authentication type name
     */
    String getAuthenticationType();
}
