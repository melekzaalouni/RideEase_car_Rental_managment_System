package com.RideEase_car_Rental_managment_System.entity;

import com.RideEase_car_Rental_managment_System.enumeration.RoleName;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name="role")
public class Role {
	@Id 
	@GeneratedValue
	@Column(name="role_id")
	private Long id ; 
	@Enumerated(EnumType.STRING)
	@Column(name="role_name")
	private RoleName name ;
	
	public Role() {
		super();
	}
	public Role(Long id, RoleName name) {
		
		this.id = id;
		this.name = name;
	}
	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}
	public RoleName getName() {
		return name;
	}
	public void setName(RoleName name) {
		this.name = name;
	}
	

}
