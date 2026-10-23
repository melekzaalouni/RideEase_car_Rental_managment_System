package com.RideEase_car_Rental_managment_System.controller;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.RideEase_car_Rental_managment_System.DTO.PageResponseDTO;
import com.RideEase_car_Rental_managment_System.DTO.UserResponseDTO;
import com.RideEase_car_Rental_managment_System.security.AdminUserService;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    private final AdminUserService adminUserService;

    private final com.RideEase_car_Rental_managment_System.service.StatisticsService statisticsService;

    public AdminController(AdminUserService adminUserService,
            com.RideEase_car_Rental_managment_System.service.StatisticsService statisticsService) {
        this.adminUserService = adminUserService;
        this.statisticsService = statisticsService;
    }

    @GetMapping("/statistics")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> statistics() {
        return ResponseEntity.ok(statisticsService.getDashboard());
    }

    @org.springframework.web.bind.annotation.PutMapping("/users/{id}/enable")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UserResponseDTO> enable(@PathVariable Long id) {
        return ResponseEntity.ok(adminUserService.setEnabled(id, true));
    }

    @org.springframework.web.bind.annotation.PutMapping("/users/{id}/disable")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UserResponseDTO> disable(@PathVariable Long id) {
        return ResponseEntity.ok(adminUserService.setEnabled(id, false));
    }

    @org.springframework.web.bind.annotation.PutMapping("/users/{id}/roles")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UserResponseDTO> roles(@PathVariable Long id,
            @org.springframework.web.bind.annotation.RequestBody
            java.util.Set<com.RideEase_car_Rental_managment_System.enumeration.RoleName> roles) {
        return ResponseEntity.ok(adminUserService.updateRoles(id, roles));
    }

    @GetMapping("/users")
    @PreAuthorize("hasAnyRole('ADMIN', 'EMPLOYEE')")
    public ResponseEntity<?> getAllUsers() {

        Pageable pageable = PageRequest.of(0, 50);
        PageResponseDTO<?> users = adminUserService.getAllUsers ( pageable);
        return ResponseEntity.status(200).body(users) ;
    }

    @GetMapping("/users/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'EMPLOYEE')")
    public ResponseEntity<UserResponseDTO> getUserById(
            @PathVariable Long id) {

        UserResponseDTO user =
                adminUserService.getUserById(id);

        return ResponseEntity.ok(user);
    }
}