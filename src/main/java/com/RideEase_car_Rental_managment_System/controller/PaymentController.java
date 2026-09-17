package com.RideEase_car_Rental_managment_System.controller;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.RideEase_car_Rental_managment_System.DTO.PaymentRequestDTO;
import com.RideEase_car_Rental_managment_System.DTO.PaymentResponseDTO;
import com.RideEase_car_Rental_managment_System.service.PaymentService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/payments")
public class PaymentController {
	private final PaymentService paymentService ;
	public PaymentController(PaymentService paymentService) {
		super();
		this.paymentService = paymentService;
	}
	@PostMapping
	public ResponseEntity<PaymentResponseDTO>  processPayment (@Valid @RequestBody PaymentRequestDTO dto ){
		PaymentResponseDTO payment = paymentService.processPayment(dto);
		return ResponseEntity.status(201).body(payment) ;
	}
	@PreAuthorize("hasAnyRole('ADMIN', 'EMPLOYEE') or @securityService.isPaymentOwner(#id, authentication)")
	@GetMapping("/{id}")
	public ResponseEntity<PaymentResponseDTO> getPayment(@PathVariable Long id){
		PaymentResponseDTO payment = paymentService.getPaymentById(id);
		return ResponseEntity.status(200).body(payment) ;
	}
	
	

}
