package com.RideEase_car_Rental_managment_System.security;

import com.RideEase_car_Rental_managment_System.DTO.RegisterRequestDTO;
import com.RideEase_car_Rental_managment_System.DTO.UserResponseDTO;
import com.RideEase_car_Rental_managment_System.entity.Customer;
import com.RideEase_car_Rental_managment_System.entity.Role;
import com.RideEase_car_Rental_managment_System.entity.User;
import com.RideEase_car_Rental_managment_System.repository.*;

import jakarta.transaction.Transactional;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
@Service
public class AuthRegistrationService {
	private final UserRespository  userRepository;
	private final RoleRepository roleRepository;
	private final PasswordEncoder passwordEncoder ;
	private final CustumerRepository customerRepository ; 
	public AuthRegistrationService(UserRespository userRepository, RoleRepository roleRepository,
			PasswordEncoder passwordEncoder ,CustumerRepository customerRepository) {
		super();
		this.userRepository = userRepository;
		this.roleRepository = roleRepository;
		this.passwordEncoder = passwordEncoder;
		this.customerRepository= customerRepository;
	}
	public Customer convertToCustomr (RegisterRequestDTO dto) {
		Customer customer= new Customer ();
		customer.setUsername(dto.getUsername());
		customer.setCreatedAtAudit(LocalDateTime.now());
		customer.setDriverLicenseNumber(dto.getDriverLicenseNumber());
		customer.setEmail(dto.getEmail());
		customer.setFirstName(dto.getFirstName());
		customer.setLastName(dto.getLastName());
		customer.setPhoneNumber(dto.getPhoneNumber());
		customer.setRegistrationDate(dto.getRegistrationDate());
		return customer ;

	}
	@Transactional
	public UserResponseDTO register(RegisterRequestDTO dto) {

	    // 1. Check if username or email already exists
	    if (userRepository.existsByUsername(dto.getUsername())
	            || userRepository.existsByEmail(dto.getEmail())) {

	        throw new RuntimeException("Username or email already exists");
	    }

	    // 2. Create CUSTOMER
	    Customer customer = convertToCustomr(dto);
	    customer = customerRepository.save(customer);

	    // 3. Create USER
	    User user = new User();

	    user.setUsername(dto.getUsername());
	    user.setEmail(dto.getEmail());
	    user.setPasswordHash(passwordEncoder.encode(dto.getPassword()));
	    user.setCreatedAt(LocalDateTime.now());
	    user.setEnabled(true);

	    // 4. Give CUSTOMER role automatically
	    Role role = roleRepository.findById(2L)
	            .orElseThrow(() -> new RuntimeException("CUSTOMER role not found"));

	    Set<Role> roles = new HashSet<>();
	    roles.add(role);

	    user.setRoles(roles);

	    // 5. Connect User with Customer
	    user.setCustomer(customer);

	    // 6. Save User
	    User savedUser = userRepository.save(user);

	    return convertToResponseDTO(savedUser);
	}
	public UserResponseDTO convertToResponseDTO(User user) {
		UserResponseDTO dto = new UserResponseDTO();
		dto.setId(user.getId());
		dto.setEmail(user.getEmail());
		dto.setEnabled(user.isEnabled());
		dto.setCreatedAt(user.getCreatedAt());
		dto.setUsername(user.getUsername());
		return dto ; 

	}
}
