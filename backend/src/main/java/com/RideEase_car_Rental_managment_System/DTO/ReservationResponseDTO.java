package com.RideEase_car_Rental_managment_System.DTO;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import com.RideEase_car_Rental_managment_System.entity.Customer;
import com.RideEase_car_Rental_managment_System.entity.Vehicle;
import com.RideEase_car_Rental_managment_System.enumeration.ReservationStatus;

public class ReservationResponseDTO {
	private Long id ; 
	private Customer customer;
	private Vehicle vehicle;
	private LocalDate startDate;
	private LocalDate endDate;
	private BigDecimal totalPrice;
	private ReservationStatus status ;
	private LocalDateTime  createdAt;
	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}
	public Customer getCustomer() {
		return customer;
	}
	public void setCustomer(Customer customer) {
		this.customer = customer;
	}
	public Vehicle getVehicle() {
		return vehicle;
	}
	public void setVehicle(Vehicle vehicle) {
		this.vehicle = vehicle;
	}
	public LocalDate getStartDate() {
		return startDate;
	}
	public void setStartDate(LocalDate startDate) {
		this.startDate = startDate;
	}
	public LocalDate getEndDate() {
		return endDate;
	}
	public void setEndDate(LocalDate endDate) {
		this.endDate = endDate;
	}
	public BigDecimal getTotalPrice() {
		return totalPrice;
	}
	public void setTotalPrice(BigDecimal totalPrice) {
		this.totalPrice = totalPrice;
	}
	public ReservationStatus getStatus() {
		return status;
	}
	public void setStatus(ReservationStatus status) {
		this.status = status;
	}
	public LocalDateTime getCreatedAt() {
		return createdAt;
	}
	public void setCreatedAt(LocalDateTime createdAt) {
		this.createdAt = createdAt;
	}
	
}
