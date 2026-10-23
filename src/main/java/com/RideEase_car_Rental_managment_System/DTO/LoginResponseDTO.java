package com.RideEase_car_Rental_managment_System.DTO;
import java.util.Set;
import com.RideEase_car_Rental_managment_System.enumeration.RoleName;
public class LoginResponseDTO {
	private String token;
	private String tokenType="Bearer";
	private String username;
	private Set<RoleName> roles ;
	public String getToken() {
		return token;
	}
	public void setToken(String token) {
		this.token = token;
	}
	public String getTokenType() {
		return tokenType;
	}
	public void setTokenType(String tokenType) {
		this.tokenType = tokenType;
	}
	public String getUsername() {
		return username;
	}
	public void setUsername(String username) {
		this.username = username;
	}
	public Set<RoleName> getRoles() {
		return roles;
	}
	public void setRoles(Set<RoleName> set) {
		this.roles = set;
	} 
	
}
