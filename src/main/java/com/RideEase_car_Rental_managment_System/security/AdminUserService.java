package com.RideEase_car_Rental_managment_System.security;
import org.springframework.data.domain.Pageable;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import org.springframework.data.domain.Page;
import org.springframework.stereotype.Service;
import com.RideEase_car_Rental_managment_System.DTO.*;
import com.RideEase_car_Rental_managment_System.entity.Role;
import com.RideEase_car_Rental_managment_System.entity.User;
import com.RideEase_car_Rental_managment_System.enumeration.RoleName;
import com.RideEase_car_Rental_managment_System.repository.RoleRepository;
import com.RideEase_car_Rental_managment_System.repository.UserRespository;
import jakarta.transaction.Transactional;
@Service 
public class AdminUserService {
	public final UserRespository userRepository ;  
	public final RoleRepository roleRopository ;
	public AdminUserService(UserRespository userRepository, RoleRepository roleRopository) {
		super();
		this.userRepository = userRepository;
		this.roleRopository = roleRopository;
	}
	private UserResponseDTO toUserResponse(User user) {
	    return new UserResponseDTO(
	        user.getId(),
	        user.getUsername(),
	        user.getEmail(),
	        user.isEnabled(),
	        user.getCreatedAt()
	    );
	}
	public UserResponseDTO getUserById(Long userId) {

	    User user = userRepository.findById(userId)
	            .orElseThrow(() ->
	                new RuntimeException("User not found"));

	    return toUserResponse(user);
	}
	@Transactional 
	public PageResponseDTO<UserResponseDTO> getAllUsers (Pageable pageable){
		Page<User> page = userRepository.findAll(pageable);
		List<UserResponseDTO> users = new ArrayList<>();
		for ( User user : page.getContent()) {
			users.add(toUserResponse(user));
		}
		return new PageResponseDTO<>(
			    users,
			    (long) page.getNumber(),
			    (long) page.getSize(),
			    page.getTotalElements(),
			    (long) page.getTotalPages()
			);
	}
	public UserResponseDTO setEnabled(Long userId, boolean
			enabled) {
		User user = userRepository.findById(userId).orElseThrow(()->new RuntimeException("error "));
		user.setEnabled(enabled);
		return toUserResponse(userRepository.save(user));
	}
	public UserResponseDTO updateRoles(Long userId,
			Set<RoleName> roles) {
		User user = userRepository.findById(userId).orElseThrow(()->new RuntimeException("error "));
		List <Role> roless = roleRopository.findAll();
		Set<Role> roleUpdate = new HashSet<>();
		for (Role role : roless) {
			if (roles.contains(role.getName())) {
				roleUpdate.add(role);}
		}
		user.setRoles(roleUpdate);
		return toUserResponse(userRepository.save(user));
		
	}
}
