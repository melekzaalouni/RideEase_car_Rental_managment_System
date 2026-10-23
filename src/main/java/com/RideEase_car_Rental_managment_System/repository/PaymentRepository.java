package com.RideEase_car_Rental_managment_System.repository;

import java.math.BigDecimal;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.RideEase_car_Rental_managment_System.entity.Payment;
import com.RideEase_car_Rental_managment_System.enumeration.PaymentStatus;

public interface PaymentRepository extends JpaRepository<Payment, Long> {
	Optional<Payment> findByReservationId(Long reservationId);
	boolean existsByReservationId(Long reservationId);

	@Query("SELECT COALESCE(SUM(p.amount), 0) FROM Payment p WHERE p.paymentStatus = :status")
	BigDecimal sumAmountByPaymentStatus(@Param("status") PaymentStatus status);

	Long countByPaymentStatus(PaymentStatus paymentStatus);
}