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

    public AdminController(AdminUserService adminUserService) {
        this.adminUserService = adminUserService;
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