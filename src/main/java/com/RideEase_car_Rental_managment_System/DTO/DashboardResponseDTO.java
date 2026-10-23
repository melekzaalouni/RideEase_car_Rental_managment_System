package com.RideEase_car_Rental_managment_System.DTO;

import java.math.BigDecimal;

public class DashboardResponseDTO {
	private Long totalCustomers;
	private Long totalVehicles;
	private Long availableVehicles;
	private Long rentedVehicles;
	private Long maintenanceVehicles;
	private Long pendingReservations;
	private Long confirmedReservations;
	private Long cancelledReservations;
	private Long totalPayments;
	private BigDecimal  revenue;
	
	public DashboardResponseDTO() {
		super();
	}

	public DashboardResponseDTO(Long totalCustomers, Long totalVehicles, Long availableVehicles, Long rentedVehicles,
			Long maintenanceVehicles, Long pendingReservations, Long confirmedReservations, Long cancelledReservations,
			Long totalPayments, BigDecimal revenue) {
		super();
		this.totalCustomers = totalCustomers;
		this.totalVehicles = totalVehicles;
		this.availableVehicles = availableVehicles;
		this.rentedVehicles = rentedVehicles;
		this.maintenanceVehicles = maintenanceVehicles;
		this.pendingReservations = pendingReservations;
		this.confirmedReservations = confirmedReservations;
		this.cancelledReservations = cancelledReservations;
		this.totalPayments = totalPayments;
		this.revenue = revenue;
	}

	public Long getTotalCustomers() {
		return totalCustomers;
	}

	public void setTotalCustomers(Long totalCustomers) {
		this.totalCustomers = totalCustomers;
	}

	public Long getTotalVehicles() {
		return totalVehicles;
	}

	public void setTotalVehicles(Long totalVehicles) {
		this.totalVehicles = totalVehicles;
	}

	public Long getAvailableVehicles() {
		return availableVehicles;
	}

	public void setAvailableVehicles(Long availableVehicles) {
		this.availableVehicles = availableVehicles;
	}

	public Long getRentedVehicles() {
		return rentedVehicles;
	}

	public void setRentedVehicles(Long rentedVehicles) {
		this.rentedVehicles = rentedVehicles;
	}

	public Long getMaintenanceVehicles() {
		return maintenanceVehicles;
	}

	public void setMaintenanceVehicles(Long maintenanceVehicles) {
		this.maintenanceVehicles = maintenanceVehicles;
	}

	public Long getPendingReservations() {
		return pendingReservations;
	}

	public void setPendingReservations(Long pendingReservations) {
		this.pendingReservations = pendingReservations;
	}

	public Long getConfirmedReservations() {
		return confirmedReservations;
	}

	public void setConfirmedReservations(Long confirmedReservations) {
		this.confirmedReservations = confirmedReservations;
	}

	public Long getCancelledReservations() {
		return cancelledReservations;
	}

	public void setCancelledReservations(Long cancelledReservations) {
		this.cancelledReservations = cancelledReservations;
	}

	public Long getTotalPayments() {
		return totalPayments;
	}

	public void setTotalPayments(Long totalPayments) {
		this.totalPayments = totalPayments;
	}

	public BigDecimal getRevenue() {
		return revenue;
	}

	public void setRevenue(BigDecimal revenue) {
		this.revenue = revenue;
	}
	
	

}
