package com.RideEase_car_Rental_managment_System.controller;
import java.security.Principal;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PostAuthorize;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.RideEase_car_Rental_managment_System.DTO.ReservationRequestDTO;
import com.RideEase_car_Rental_managment_System.DTO.ReservationResponseDTO;
import com.RideEase_car_Rental_managment_System.entity.Reservation;
import com.RideEase_car_Rental_managment_System.repository.ReservationRepository;
import com.RideEase_car_Rental_managment_System.service.ReservationService;
import jakarta.validation.Valid;
@RestController
@RequestMapping("/api/reservations")
public class ReservationController {
	public final ReservationService reservationService;
	public final ReservationRepository reservationRepository;
	
	public ReservationController(ReservationService reservationService, ReservationRepository reservationRepository) {
		super();
		this.reservationService = reservationService;
		this.reservationRepository = reservationRepository;
	}
	@PostMapping
	public ResponseEntity<ReservationResponseDTO> createReservation (@Valid @RequestBody ReservationRequestDTO dto){
		ReservationResponseDTO reservation = reservationService.createReservation(dto);
		return ResponseEntity.status(HttpStatus.CREATED).body(reservation);
	}
	@GetMapping("/{id}")
	@PostAuthorize("@securityService.isReservationOwner(#id, authentication) or hasAnyRole('ADMIN','EMPLOYEE')")

	public ResponseEntity<ReservationResponseDTO> getReservation(@PathVariable Long id){
		ReservationResponseDTO reservation = reservationService.getReservationById(id);
		return ResponseEntity.status(HttpStatus.OK).body(reservation);
	}
	@GetMapping("/customers/{customerId}")
	@PreAuthorize(
		    "hasAnyRole('ADMIN','EMPLOYEE') or " +
		    "@securityService.isCustomerOwner(#customerId, authentication)"
		)	public ResponseEntity<List<ReservationResponseDTO>> getReservationsByCustomer (@PathVariable Long customerId){
		List <ReservationResponseDTO> reservations = reservationService.getReservationsByCustomer(customerId);
		return ResponseEntity.status(HttpStatus.OK).body(reservations);
	}
	@PutMapping("/{id}/cancel")
	public ResponseEntity<?> cancelReservation(@PathVariable Long id , Principal principal ){
		/*reservationService.cancelReservation(id);
		return ResponseEntity.status(HttpStatus.OK);*/
		Reservation reservation = reservationRepository.findById(id).orElseThrow();
		boolean isOwner =reservation.getCustomer().getUsername().equals(principal.getName());
		boolean isStaff = SecurityContextHolder.getContext().getAuthentication().getAuthorities()
				.stream().anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN")|| a.getAuthority().equals("ROLE_EMPLOYEE"));
		if(!isOwner && !isStaff) {
			return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Access denied.");
			
		}
		reservationService.cancelReservation(id);
	    return ResponseEntity.status(200).body("Reservation cancelled successfully");
		
	}
	
	
	
	
}
