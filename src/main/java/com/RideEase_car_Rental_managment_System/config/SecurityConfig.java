package com.RideEase_car_Rental_managment_System.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import com.RideEase_car_Rental_managment_System.repository.CustumerRepository;
import com.RideEase_car_Rental_managment_System.repository.PaymentRepository;
import com.RideEase_car_Rental_managment_System.repository.ReservationRepository;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthFilter;
    private final PaymentRepository paymentRepository;
    private final ReservationRepository reservationRepository;
    private final CustumerRepository customerRepository;

    public SecurityConfig(
            JwtAuthenticationFilter jwtAuthFilter,
            PaymentRepository paymentRepository,
            ReservationRepository reservationRepository,
            CustumerRepository customerRepository) {

        this.jwtAuthFilter = jwtAuthFilter;
        this.paymentRepository = paymentRepository;
        this.reservationRepository = reservationRepository;
        this.customerRepository = customerRepository;
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {

        http

            // =========================
            // CSRF
            // =========================
            .csrf(AbstractHttpConfigurer::disable)

            // =========================
            // H2 CONSOLE
            // =========================
            .headers(headers -> headers
                .frameOptions(frame -> frame.disable())
            )

            // =========================
            // SESSION
            // =========================
            .sessionManagement(session ->
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )

            // =========================
            // AUTHORIZATION
            // =========================
            .authorizeHttpRequests(auth -> auth

                // -------------------------
                // PUBLIC ENDPOINTS
                // -------------------------
                .requestMatchers("/api/auth/**").permitAll()

                .requestMatchers(
                    "/v3/api-docs/**",
                    "/swagger-ui/**",
                    "/swagger-ui.html",
                    "/h2-console/**"
                ).permitAll()

                // Anyone can see vehicles
                .requestMatchers(HttpMethod.GET, "/api/vehicles/**")
                    .permitAll()

                // -------------------------
                // ADMIN ONLY
                // -------------------------
                .requestMatchers(HttpMethod.DELETE, "/api/customers/**")
                    .hasRole("ADMIN")

                .requestMatchers("/api/admin/**")
                    .hasRole("ADMIN")

                // -------------------------
                // ADMIN & EMPLOYEE
                // -------------------------

                // User oversight
                .requestMatchers(HttpMethod.GET, "/api/users/**")
                    .hasAnyRole("ADMIN", "EMPLOYEE")

                // Vehicle management
                .requestMatchers(HttpMethod.POST, "/api/vehicles/**")
                    .hasAnyRole("ADMIN", "EMPLOYEE")

                .requestMatchers(HttpMethod.PUT, "/api/vehicles/**")
                    .hasAnyRole("ADMIN", "EMPLOYEE")

                .requestMatchers(HttpMethod.DELETE, "/api/vehicles/**")
                    .hasAnyRole("ADMIN", "EMPLOYEE")

                // Global reservations
                .requestMatchers(HttpMethod.GET, "/api/reservations")
                    .hasAnyRole("ADMIN", "EMPLOYEE")

                // Global payments
                .requestMatchers(HttpMethod.GET, "/api/payments")
                    .hasAnyRole("ADMIN", "EMPLOYEE")

                // -------------------------
                // CUSTOMER / SHARED
                // -------------------------

                .requestMatchers("/api/reservations/**")
                    .hasAnyRole("CUSTOMER", "EMPLOYEE", "ADMIN")

                .requestMatchers("/api/payments/**")
                    .hasAnyRole("CUSTOMER", "EMPLOYEE", "ADMIN")

                .requestMatchers("/api/customers/**")
                    .hasAnyRole("CUSTOMER", "EMPLOYEE", "ADMIN")

                // -------------------------
                // EVERYTHING ELSE
                // -------------------------
                .anyRequest().authenticated()
            )

            // =========================
            // JWT FILTER
            // =========================
            .addFilterBefore(
                jwtAuthFilter,
                UsernamePasswordAuthenticationFilter.class
            );

        return http.build();
    }

    // =========================================================
    // PAYMENT OWNERSHIP
    // =========================================================

    public boolean isPaymentOwner(
            Long paymentId,
            Authentication authentication) {

        var paymentOptional = paymentRepository.findById(paymentId);

        if (paymentOptional.isEmpty()) {
            return false;
        }

        var payment = paymentOptional.get();

        return payment.getReservation()
                .getCustomer()
                .getUsername()
                .equals(authentication.getName());
    }

    // =========================================================
    // CUSTOMER OWNERSHIP
    // =========================================================

    public boolean isCustomerOwner(
            Long customerId,
            Authentication authentication) {

        var customerOptional = customerRepository.findById(customerId);

        if (customerOptional.isEmpty()) {
            return false;
        }

        var customer = customerOptional.get();

        return customer.getUsername()
                .equals(authentication.getName());
    }

    // =========================================================
    // RESERVATION OWNERSHIP
    // =========================================================

    public boolean isReservationOwner(
            Long reservationId,
            Authentication authentication) {

        var reservationOptional =
                reservationRepository.findById(reservationId);

        if (reservationOptional.isEmpty()) {
            return false;
        }

        var reservation = reservationOptional.get();

        return reservation.getCustomer()
                .getUsername()
                .equals(authentication.getName());
    }

    // =========================================================
    // AUTHENTICATION MANAGER
    // =========================================================

    @Bean
    public AuthenticationManager authenticationManager(
            AuthenticationConfiguration config) throws Exception {

        return config.getAuthenticationManager();
    }
}