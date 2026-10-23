package com.RideEase_car_Rental_managment_System.DTO;

import java.math.BigDecimal;

import com.RideEase_car_Rental_managment_System.enumeration.VehicleCategory;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class VehicleRequestDTO {
	@NotBlank
	private String licensePlate;
	@NotBlank
	private String brand;
	@NotBlank
	private String model;
	@NotNull
	private VehicleCategory category;
	@NotNull
	@DecimalMin("0.01")
	private BigDecimal dailyRate;
	@NotNull
	@Min(1990)
	private int yearOfManufacture;
	@NotNull
	private Long version ;
	
	public Long getVersion() {
		return version;
	}
	public void setVersion(Long version) {
		this.version = version;
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
	public int getYearOfManufacture() {
		return yearOfManufacture;
	}
	public void setYearOfManufacture(int yearOfManufacture) {
		this.yearOfManufacture = yearOfManufacture;
	}
	
	
	
	
	
}
