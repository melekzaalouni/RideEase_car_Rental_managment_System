package com.RideEase_car_Rental_managment_System.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.RideEase_car_Rental_managment_System.DTO.LoginRequestDTO;
import com.RideEase_car_Rental_managment_System.DTO.LoginResponseDTO;
import com.RideEase_car_Rental_managment_System.DTO.RegisterRequestDTO;
import com.RideEase_car_Rental_managment_System.DTO.UserResponseDTO;
import com.RideEase_car_Rental_managment_System.security.*;

import jakarta.validation.Valid;

@RestController 
@RequestMapping("/api/auth")
public class AuthController {
	private final AuthRegistrationService authRegistrationService;
	private final  AuthenticationService authentificationService ;
	

	public AuthController(AuthRegistrationService authRegistrationService,
			AuthenticationService authentificationService) {
		super();
		this.authRegistrationService = authRegistrationService;
		this.authentificationService = authentificationService;
	}
	@PostMapping("/register")
	public ResponseEntity<UserResponseDTO> register (@Valid @RequestBody RegisterRequestDTO dto ){
		UserResponseDTO userR =authRegistrationService.register(dto);
		return ResponseEntity.status(201).body(userR); 
	}
	@PostMapping("/login")
	public ResponseEntity<LoginResponseDTO> login (@Valid @RequestBody LoginRequestDTO dto ){
		LoginResponseDTO userR =authentificationService.login(dto);
		return ResponseEntity.status(200).body(userR); 
	}
}
