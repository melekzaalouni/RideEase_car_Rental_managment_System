package com.RideEase_car_Rental_managment_System.DTO;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import com.RideEase_car_Rental_managment_System.entity.Reservation;
import com.RideEase_car_Rental_managment_System.enumeration.PaymentMethod;
import com.RideEase_car_Rental_managment_System.enumeration.PaymentStatus;

public class PaymentResponseDTO {
	private Long id ; 
	private Reservation reservation ; 
	private BigDecimal amount ;
	private PaymentMethod paymentMethod ;
	private PaymentStatus paymentStatus ;
	private LocalDateTime paymentDate ;
	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}
	public Reservation getReservation() {
		return reservation;
	}
	public void setReservation(Reservation reservation) {
		this.reservation = reservation;
	}
	public BigDecimal getAmount() {
		return amount;
	}
	public void setAmount(BigDecimal amount) {
		this.amount = amount;
	}
	public PaymentMethod getPaymentMethod() {
		return paymentMethod;
	}
	public void setPaymentMethod(PaymentMethod paymentMethod) {
		this.paymentMethod = paymentMethod;
	}
	public PaymentStatus getPaymentStatus() {
		return paymentStatus;
	}
	public void setPaymentStatus(PaymentStatus paymentStatus) {
		this.paymentStatus = paymentStatus;
	}
	public LocalDateTime getPaymentDate() {
		return paymentDate;
	}
	public void setPaymentDate(LocalDateTime paymentDate) {
		this.paymentDate = paymentDate;
	}
	
	
	
}
