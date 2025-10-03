package com.hilgo.rotax.config;

import java.io.IOException;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import com.hilgo.rotax.entity.User;
import com.hilgo.rotax.service.JwtService;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtService jwtService;
    private final UserDetailsService userDetailsService;

    // JwtAuthenticationFilter.java - doFilterInternal metodunun daha verimli hali

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        final String authHeader = request.getHeader("Authorization");
        final String jwt;
        final String username;

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        jwt = authHeader.substring(7);
        username = jwtService.extractUsername(jwt);

        if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            // 1. Kullanıcıyı SADECE BİR KEZ UserDetailsService ile çekiyoruz.
            UserDetails userDetails = userDetailsService.loadUserByUsername(username);

            // 2. 'active' kontrolü için UserDetails'i kendi User tipimize cast ediyoruz.
            // Bu işlem veritabanına TEKRAR gitmez.
            if (userDetails instanceof User) {
                User user = (User) userDetails;
                if (!user.getEnabled()) {
                    // Burada hata fırlatmak yerine, isteği reddetmek daha doğru olabilir.
                    // response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    // return;
                    throw new RuntimeException("User is not active");
                }
            }

            if (jwtService.isTokenValid(jwt, userDetails)) {
                UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                        userDetails,
                        null,
                        userDetails.getAuthorities()
                );
                authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(authToken);
            }
        }
        filterChain.doFilter(request, response);
    }
}