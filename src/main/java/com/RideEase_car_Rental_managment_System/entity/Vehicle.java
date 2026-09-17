package com.RideEase_car_Rental_managment_System.entity;

import java.math.BigDecimal;

import com.RideEase_car_Rental_managment_System.enumeration.VehicleCategory;
import com.RideEase_car_Rental_managment_System.enumeration.VehicleStatus;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name="Vehicle")
public class Vehicle extends Auditable{
	@Id 
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name="vehicle_id")
	private Long id  ; 
	@Column(name="license_plate" , nullable= false , unique = true )
	private String licensePlate ;
	@Column(name="brand" , nullable = false)
	private String brand ;
	@Column(name="model", nullable = false)
	private String model ;
	@Enumerated(EnumType.STRING)
	@Column(name="category", nullable = false)
	private VehicleCategory category ;
	@Column(name="daily_rate", nullable = false)
	private BigDecimal  dailyRate ;
	@Enumerated(EnumType.STRING)
	@Column(name="status", nullable = false)
	private VehicleStatus status ;
	@Column(name="year_of_manufacture", nullable = false)
	private int yearOfManufacture ;
	@Column(name="version", nullable = false)
	private Long version ; 
	
	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}
	public String getLicensePlate() {
		return licensePlate;
	}
	public void setLicensePlate(String licensePlate) {
		this.licensePlate = licensePlate;
	}
	public String getBrand() {
		return brand;
	}
	public void setBrand(String brand) {
		this.brand = brand;
	}
	public String getModel() {
		return model;
	}
	public void setModel(String model) {
		this.model = model;
	}
	public VehicleCategory getCategory() {
		return category;
	}
	public void setCategory(VehicleCategory category) {
		this.category = category;
	}
	public BigDecimal getDailyRate() {
		return dailyRate;
	}
	public void setDailyRate(BigDecimal dailyRate) {
		this.dailyRate = dailyRate;
	}
	public VehicleStatus getStatus() {
		return status;
	}
	public void setStatus(VehicleStatus status) {
		this.status = status;
	}
	public int getYearOfManufacture() {
		return yearOfManufacture;
	}
	public void setYearOfManufacture(int yearOfManufacture) {
		this.yearOfManufacture = yearOfManufacture;
	}
	public Long getVersion() {
		return version;
	}
	public void setVersion(Long version) {
		this.version = version;
	}
	
	
	
	

}
