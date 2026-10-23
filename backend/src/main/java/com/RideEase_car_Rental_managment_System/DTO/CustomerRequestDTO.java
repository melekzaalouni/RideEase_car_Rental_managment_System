package com.RideEase_car_Rental_managment_System.DTO;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.*;
public class CustomerRequestDTO {
	@NotBlank
	private String firstName ; 
	@NotBlank
	private String lastName;
	@NotBlank 
	@Email
	private String email ; 
	@NotBlank
	@Size(min=8, max=8)
	private String phoneNumber;
	@Size(min=5, max=30)
	private String driverLicenseNumber;
	public String getFirstName() {
		return firstName;
	}
	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}
	public String getLastName() {
		return lastName;
	}
	public void setLastName(String lastName) {
		this.lastName = lastName;
	}
	public String getEmail() {
		return email;
	}
	public void setEmail(String email) {
		this.email = email;
	}
	public String getPhoneNumber() {
		return phoneNumber;
	}
	public void setPhoneNumber(String phoneNumber) {
		this.phoneNumber = phoneNumber;
	}
	public String getDriverLicenseNumber() {
		return driverLicenseNumber;
	}
	public void setDriverLicenseNumber(String driverLicenseNumber) {
		this.driverLicenseNumber = driverLicenseNumber;
	}
	
	
	
}
	
	