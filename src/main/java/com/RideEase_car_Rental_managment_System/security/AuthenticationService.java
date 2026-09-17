package com.RideEase_car_Rental_managment_System.security;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.RideEase_car_Rental_managment_System.DTO.LoginRequestDTO;
import com.RideEase_car_Rental_managment_System.DTO.LoginResponseDTO;
import com.RideEase_car_Rental_managment_System.entity.Role;
import com.RideEase_car_Rental_managment_System.entity.User;
import com.RideEase_car_Rental_managment_System.enumeration.RoleName;
import com.RideEase_car_Rental_managment_System.repository.RoleRepository;
import com.RideEase_car_Rental_managment_System.repository.UserRespository;

@Service 
public class AuthenticationService {
	private final UserRespository userRepository ; 
	private final PasswordEncoder passwordEncoder ;
	private JwtService jwtService;
	public AuthenticationService(UserRespository userRepository,PasswordEncoder passwordEncoder,JwtService jwtService) {
		super();
		this.userRepository = userRepository;
		this.passwordEncoder= passwordEncoder;
		this.jwtService= jwtService;
	}
	//pour le teste
	/*
	@Bean
	CommandLineRunner seedUser(
	        UserRespository repo,
	        RoleRepository roleRepository,
	        PasswordEncoder encoder) {

	    return args -> {

	        // Create ADMIN
	        if (repo.findByUsername("admin").isEmpty()) {

	            User admin = new User();

	            admin.setUsername("admin");
	            admin.setEmail("admin@rideease.com");
	            admin.setPasswordHash(encoder.encode("admin123"));
	            admin.setEnabled(true);
	            admin.setCreatedAt(LocalDateTime.now());

	            Role adminRole = roleRepository.findById(1L)
	                    .orElseThrow(() ->
	                        new RuntimeException("ADMIN role not found"));

	            Set<Role> roles = new HashSet<>();
	            roles.add(adminRole);

	            admin.setRoles(roles);

	            repo.save(admin);
	        }

	        // Create EMPLOYEE
	        if (repo.findByUsername("employee").isEmpty()) {

	            User employee = new User();

	            employee.setUsername("employee");
	            employee.setEmail("employee@rideease.com");
	            employee.setPasswordHash(encoder.encode("employee123"));
	            employee.setEnabled(true);
	            employee.setCreatedAt(LocalDateTime.now());

	            Role employeeRole = roleRepository.findById(3L)
	                    .orElseThrow(() ->
	                        new RuntimeException("EMPLOYEE role not found"));

	            Set<Role> roles = new HashSet<>();
	            roles.add(employeeRole);

	            employee.setRoles(roles);

	            repo.save(employee);
	        }
	    };
	}*/
	public LoginResponseDTO login (LoginRequestDTO dto) {
		User user = userRepository.findByUsername(dto.getUsername()).orElseThrow(()->new RuntimeException("username not found"));
		if(!passwordEncoder.matches(
		        dto.getPassword(),
		        user.getPasswordHash())) {
			throw new RuntimeException("password incorrect ");
		}
		if (!user.isEnabled()) {
            throw new RuntimeException("Account is disabled");
        }
		String token =jwtService.generateToken(user);
		LoginResponseDTO response = new LoginResponseDTO();

        response.setToken(token);
        response.setTokenType("Bearer");
        response.setUsername(user.getUsername());
        response.setRoles(
        	    user.getRoles()
        	        .stream()
        	        .map(role -> role.getName())
        	        .collect(Collectors.toSet())
        	);
		
		return response;			
		
	}

}
