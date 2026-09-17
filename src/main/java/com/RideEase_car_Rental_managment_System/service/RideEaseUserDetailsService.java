package com.RideEase_car_Rental_managment_System.service;

import java.util.stream.Collectors;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.RideEase_car_Rental_managment_System.entity.User;
import com.RideEase_car_Rental_managment_System.repository.UserRespository;
@Service 
public class RideEaseUserDetailsService implements UserDetailsService {
	private final UserRespository userRepository ;
	
	public RideEaseUserDetailsService(UserRespository userRepository) {
		super();
		this.userRepository = userRepository;
	}

	@Override
	public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
		User user =userRepository.findByUsername(username).orElseThrow(()-> new UsernameNotFoundException("user not found "));
		
		return new org.springframework.security.core.userdetails.User(user.getUsername(),
				user.getPasswordHash(),
				user.isEnabled(),
				true ,
				true ,
				true,
				user.getRoles().stream()
                .map(role -> new SimpleGrantedAuthority(
                    "ROLE_" + role.getName().name()))
                .collect(Collectors.toSet())		);		
	}

}
