package com.RideEase_car_Rental_managment_System.entity;

import java.time.LocalDate;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name="Customer")
public class Customer extends Auditable{
	@Id 
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name="customer_id" , nullable = false)
	private Long id ; 
	@Column(name="username" , nullable=false )
	private String username ;
	@Column(name="first_name" , nullable = false)
	private String firstName ;
	@Column(name="last_name" , nullable = false)
	private String lastName ;
	@Column(name="email" , nullable = false)
	private String email ; 
	@Column(name="phone_number" , nullable = false)
	private String phoneNumber;
	@Column(name="driver_license_number" , nullable = false)
	private String driverLicenseNumber;
	@Column(name="registration_date" , nullable = false)
	private LocalDate registrationDate;
	
	public Customer() {
		super();
	}
	
	public Customer(Long id, String username, String firstName, String lastName, String email, String phoneNumber,
			String driverLicenseNumber, LocalDate registrationDate) {
		super();
		this.id = id;
		this.username = username;
		this.firstName = firstName;
		this.lastName = lastName;
		this.email = email;
		this.phoneNumber = phoneNumber;
		this.driverLicenseNumber = driverLicenseNumber;
		this.registrationDate = registrationDate;
	}

	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}
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
	public LocalDate getRegistrationDate() {
		return registrationDate;
	}
	public void setRegistrationDate(LocalDate registrationDate) {
		this.registrationDate = registrationDate;
	}
	
	
	

}
