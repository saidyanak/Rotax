package com.hilgo.rotax.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

public class ApiKeyAuthFilter extends OncePerRequestFilter {

    private final String apiKey;
    private final String headerName;

    public ApiKeyAuthFilter(String apiKey, String headerName) {
        this.apiKey = apiKey;
        this.headerName = headerName;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        
        // Only apply to internal API paths
        if (!request.getRequestURI().startsWith("/api/internal")) {
            filterChain.doFilter(request, response);
            return;
        }
        
        // Check for API key in header
        String requestApiKey = request.getHeader(headerName);
        
        if (apiKey.equals(requestApiKey)) {
            // Create authentication token with INTERNAL_SERVICE authority
            UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                    "internal-service", null, 
                    List.of(new SimpleGrantedAuthority("INTERNAL_SERVICE")));
            
            SecurityContextHolder.getContext().setAuthentication(authentication);
        }
        
        filterChain.doFilter(request, response);
    }
}