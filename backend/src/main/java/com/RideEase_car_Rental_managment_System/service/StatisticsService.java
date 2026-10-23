package com.RideEase_car_Rental_managment_System.service;

import java.math.BigDecimal;

import org.springframework.stereotype.Service;

import com.RideEase_car_Rental_managment_System.DTO.DashboardResponseDTO;
import com.RideEase_car_Rental_managment_System.enumeration.PaymentStatus;
import com.RideEase_car_Rental_managment_System.enumeration.ReservationStatus;
import com.RideEase_car_Rental_managment_System.enumeration.VehicleStatus;
import com.RideEase_car_Rental_managment_System.repository.CustumerRepository;
import com.RideEase_car_Rental_managment_System.repository.PaymentRepository;
import com.RideEase_car_Rental_managment_System.repository.ReservationRepository;
import com.RideEase_car_Rental_managment_System.repository.VehicleRepository;

@Service
public class StatisticsService {
	private final CustumerRepository customerRepository ; 
	private final VehicleRepository vehicleRepository ;
	private final PaymentRepository paymentRepository ;
	private final ReservationRepository reservationRespository;
	public StatisticsService(CustumerRepository customerRepository, VehicleRepository vehicleRepository,
			PaymentRepository paymentRepository, ReservationRepository reservationRespository) {
		super();
		this.customerRepository = customerRepository;
		this.vehicleRepository = vehicleRepository;
		this.paymentRepository = paymentRepository;
		this.reservationRespository = reservationRespository;
	}
	public DashboardResponseDTO getDashboard() {
		Long totalCustomer = customerRepository.count();
		Long totalVehicle = vehicleRepository.count();
		Long availableVehicle = vehicleRepository.countByStatus(VehicleStatus.AVAILABLE);
		Long rentedVehicle = vehicleRepository.countByStatus(VehicleStatus.RENTED);
		Long maintenaceVehicle = vehicleRepository.countByStatus(VehicleStatus.MAINTENANCE);
		Long pendingReservation = reservationRespository.countByStatus(ReservationStatus.PENDING);
		Long confirmedReservation = reservationRespository.countByStatus(ReservationStatus.CONFIRMED);
		Long canceledReservation = reservationRespository.countByStatus(ReservationStatus.CANCELLED);
		Long totalPayment = paymentRepository.countByPaymentStatus(PaymentStatus.COMPLETED);
		BigDecimal revenue = paymentRepository.sumAmountByPaymentStatus(PaymentStatus.COMPLETED);
		return new DashboardResponseDTO(totalCustomer ,
				totalVehicle,
				availableVehicle,
				rentedVehicle,
				maintenaceVehicle,
				pendingReservation,
				confirmedReservation,
				canceledReservation,
				totalPayment,
				revenue
				);
	}
}
