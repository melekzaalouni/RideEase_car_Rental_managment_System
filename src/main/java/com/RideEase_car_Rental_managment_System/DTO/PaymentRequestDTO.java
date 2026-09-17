package com.RideEase_car_Rental_managment_System.DTO;
import java.math.BigDecimal;
import com.RideEase_car_Rental_managment_System.enumeration.PaymentMethod;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
public class PaymentRequestDTO {
	@NotNull
	private Long reservationId;
	@NotNull
	@DecimalMin("0.01")
	private BigDecimal amount;
	@NotNull
	private PaymentMethod paymentMethod ;
	public Long getReservationId() {
		return reservationId;
	}
	public void setReservationId(Long reservationId) {
		this.reservationId = reservationId;
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
	
}
