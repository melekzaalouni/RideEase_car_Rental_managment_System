package com.RideEase_car_Rental_managment_System.service;
import java.time.LocalDateTime;
import org.springframework.stereotype.Service;

import com.RideEase_car_Rental_managment_System.CustomExceptions.InvalidReservationStateException;
import com.RideEase_car_Rental_managment_System.CustomExceptions.ResourceNotFoundException;
import com.RideEase_car_Rental_managment_System.DTO.PaymentRequestDTO;
import com.RideEase_car_Rental_managment_System.DTO.PaymentResponseDTO;
import com.RideEase_car_Rental_managment_System.entity.Payment;
import com.RideEase_car_Rental_managment_System.entity.Reservation;
import com.RideEase_car_Rental_managment_System.entity.Vehicle;
import com.RideEase_car_Rental_managment_System.enumeration.PaymentStatus;
import com.RideEase_car_Rental_managment_System.enumeration.ReservationStatus;
import com.RideEase_car_Rental_managment_System.enumeration.VehicleStatus;
import com.RideEase_car_Rental_managment_System.repository.PaymentRepository;
import com.RideEase_car_Rental_managment_System.repository.ReservationRepository;
import jakarta.transaction.Transactional;
@Service
public class PaymentService {
	private final PaymentRepository paymentRepository;
	private final ReservationRepository reservationRepository ;
	public PaymentService(PaymentRepository paymentRepository, ReservationRepository reservationRepository) {
		super();
		this.paymentRepository = paymentRepository;
		this.reservationRepository = reservationRepository;
	}
	@Transactional 
	public PaymentResponseDTO processPayment (PaymentRequestDTO dto) {
		Payment payment = new Payment();
		//step 1 
		Reservation reservation = reservationRepository.findById(dto.getReservationId()).orElseThrow(()-> new ResourceNotFoundException("reservation not found "+dto.getReservationId()));
		//step 2 / 3
		if(!(reservation.getStatus().equals(ReservationStatus.PENDING)) ) {
			throw new InvalidReservationStateException("reservation had a payment");
		}
		
		Vehicle vehicle = reservation.getVehicle();		
		payment.setReservation(reservation);
		payment.setAmount(dto.getAmount());
		payment.setPaymentMethod(dto.getPaymentMethod());
		payment.setPaymentDate(LocalDateTime.now());
		
		if(dto.getAmount().compareTo(reservation.getTotalPrice()) >= 0) {
			payment.setPaymentStatus(PaymentStatus.COMPLETED);
			reservation.setStatus(ReservationStatus.CONFIRMED);
			vehicle.setStatus(VehicleStatus.RENTED);
		}
		else if(dto.getAmount().compareTo(reservation.getTotalPrice()) < 0)  {
			payment.setPaymentStatus(PaymentStatus.FAILED);
			reservation.setStatus(ReservationStatus.CANCELLED);
		}
		else {
			payment.setPaymentStatus(PaymentStatus.PENDING);
		}
		
		return convertToResponseDTO(paymentRepository.save(payment));
	}
	public PaymentResponseDTO convertToResponseDTO (Payment payment) {
		PaymentResponseDTO dto = new PaymentResponseDTO();
	    dto.setId(payment.getId());
	    dto.setReservation(payment.getReservation());
	    dto.setAmount(payment.getAmount());
	    dto.setPaymentMethod(payment.getPaymentMethod());
	    dto.setPaymentStatus(payment.getPaymentStatus());
	    dto.setPaymentDate(payment.getPaymentDate());
	    return dto;
	}
	public PaymentResponseDTO getPaymentById(Long id ) {
		return convertToResponseDTO(paymentRepository.findById(id).orElseThrow(()-> new ResourceNotFoundException("no payment with id "+ id)));
	}
	
	
}
