package com.RideEase_car_Rental_managment_System.entity;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import com.RideEase_car_Rental_managment_System.enumeration.PaymentMethod;
import com.RideEase_car_Rental_managment_System.enumeration.PaymentStatus;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;

@Entity
@Table(name="Payment")
public class Payment extends Auditable {
	@Id
	@GeneratedValue(strategy=GenerationType.IDENTITY)
	@Column(name="payment_id" , nullable=false)
	private Long id ; 
	@OneToOne
	@JoinColumn(name="reservation_id")
	private Reservation reservation ; 
	@Column(name="amount" , nullable=false)
	private BigDecimal amount ;
	@Enumerated(EnumType.STRING)
	@Column(name="payment_method" , nullable=false)
	private PaymentMethod paymentMethod ;
	@Enumerated(EnumType.STRING)
	@Column(name="payment_status" , nullable=false)
	private PaymentStatus paymentStatus ;
	@Column(name="payment_date" , nullable=false)
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
