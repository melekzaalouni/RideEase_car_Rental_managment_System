package com.RideEase_car_Rental_managment_System.service;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import com.RideEase_car_Rental_managment_System.CustomExceptions.InvalidReservationDateException;
import com.RideEase_car_Rental_managment_System.CustomExceptions.ResourceNotFoundException;
import com.RideEase_car_Rental_managment_System.CustomExceptions.VehicleNotAvailableException;
import com.RideEase_car_Rental_managment_System.DTO.ReservationRequestDTO;
import com.RideEase_car_Rental_managment_System.DTO.ReservationResponseDTO;
import com.RideEase_car_Rental_managment_System.entity.Reservation;
import com.RideEase_car_Rental_managment_System.entity.Vehicle;
import com.RideEase_car_Rental_managment_System.enumeration.ReservationStatus;
import com.RideEase_car_Rental_managment_System.enumeration.VehicleStatus;
import com.RideEase_car_Rental_managment_System.repository.CustumerRepository;
import com.RideEase_car_Rental_managment_System.repository.ReservationRepository;
import com.RideEase_car_Rental_managment_System.repository.VehicleRepository;
import jakarta.transaction.Transactional;
@Service
public class ReservationService {
	
	private final ReservationRepository reservationRepository ; 
	private final CustumerRepository customerRepository ;
	private final VehicleRepository vehicleRepository;
	
	public ReservationService(ReservationRepository reservationRepository, CustumerRepository customerRepository,
			VehicleRepository vehicleRepository) {
		super();
		this.reservationRepository = reservationRepository;
		this.customerRepository = customerRepository;
		this.vehicleRepository = vehicleRepository;
	}
	@Transactional
	public ReservationResponseDTO createReservation(ReservationRequestDTO dto) {
	    if (!dto.getEndDate().isAfter(dto.getStartDate())) {
	        throw new InvalidReservationDateException("End date must be strictly after start date");
	    }

	    Vehicle vehicle = vehicleRepository.findById(dto.getVehicleId())
	            .orElseThrow(() -> new ResourceNotFoundException("Vehicle not found"));

	    boolean overlap = !reservationRepository.findOverlapping(
	            dto.getVehicleId(), dto.getStartDate(), dto.getEndDate(),
	            List.of(ReservationStatus.PENDING, ReservationStatus.CONFIRMED)
	    ).isEmpty();

	    if (vehicle.getStatus() != VehicleStatus.AVAILABLE || overlap) {
	        throw new VehicleNotAvailableException("Vehicle not available for these dates");
	    }

	    Reservation reservation = new Reservation();
	    reservation.setStatus(ReservationStatus.PENDING);
	    reservation.setCustomer(customerRepository.findById(dto.getCustomerId())
	            .orElseThrow(() -> new ResourceNotFoundException("Customer not found")));
	    reservation.setVehicle(vehicle);
	    reservation.setStartDate(dto.getStartDate());
	    reservation.setEndDate(dto.getEndDate());

	    long numberOfDays = ChronoUnit.DAYS.between(dto.getStartDate(), dto.getEndDate());
	    reservation.setTotalPrice(vehicle.getDailyRate().multiply(BigDecimal.valueOf(numberOfDays)));
	    reservation.setCreatedAt(LocalDateTime.now());

	    return convertToResponseDTO(reservationRepository.save(reservation));
	}
	public ReservationResponseDTO getReservationById (Long id ) {
		return convertToResponseDTO(reservationRepository.findById(id).orElseThrow(()-> new ResourceNotFoundException("reservation not found")));
		
	}
	public List<ReservationResponseDTO> getReservationsByCustomer(Long customerId ){
		List <Reservation> reservations =reservationRepository.findByCustomerId(customerId);
		List <ReservationResponseDTO> responses = new ArrayList<>();
		for(Reservation reservation : reservations ) {
			responses.add(convertToResponseDTO(reservation));
		}
		return responses ; 
	}
	@Transactional 
	public ReservationResponseDTO cancelReservation (Long id) {
		Reservation reservation = reservationRepository.findById(id).orElseThrow(()-> new ResourceNotFoundException("reservation not found"));
		reservation.setStatus(ReservationStatus.CANCELLED);
		Vehicle vehicle = reservation.getVehicle();
		vehicle.setStatus(VehicleStatus.AVAILABLE);
		vehicleRepository.save(vehicle);
		reservation.setVehicle(vehicle);
		return convertToResponseDTO(reservationRepository.save(reservation));
	}
	@Scheduled(cron = "0 0 0 * * ?")
	@Transactional 
	public void returnTheStatueToAvaileble() {
		List <Reservation> reservations = reservationRepository.findAll();
		for (Reservation reservation : reservations ) {
			if(reservation.getVehicle().getStatus().equals(VehicleStatus.RENTED)&& reservation.getEndDate().equals(LocalDate.now())) {
				reservation.getVehicle().setStatus(VehicleStatus.AVAILABLE);
				reservation.setStatus(ReservationStatus.COMPLETED);
			}
		}
	}
	private ReservationResponseDTO convertToResponseDTO (Reservation reservation ) {
		ReservationResponseDTO dto = new ReservationResponseDTO();
		dto.setId(reservation.getId());
		dto.setStartDate(reservation.getStartDate());
		dto.setEndDate(reservation.getEndDate());
		dto.setCustomer(reservation.getCustomer());
		dto.setVehicle(reservation.getVehicle());
		dto.setTotalPrice(reservation.getTotalPrice());
		dto.setStatus(reservation.getStatus());
		dto.setCreatedAt(reservation.getCreatedAt());
		return dto ; 
	}
	
	
	
	
	
	
	
	
	
	
}
