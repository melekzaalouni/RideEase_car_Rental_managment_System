package com.RideEase_car_Rental_managment_System.repository;

import java.time.LocalDate;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.RideEase_car_Rental_managment_System.entity.Reservation;
import com.RideEase_car_Rental_managment_System.entity.Vehicle;
import com.RideEase_car_Rental_managment_System.enumeration.ReservationStatus;

public interface ReservationRepository extends JpaRepository<Reservation, Long>, 
JpaSpecificationExecutor<Reservation>{
	@Query("SELECT r FROM Reservation r WHERE r.vehicle.id = :vehicleId " +
		       "AND r.status IN :statuses AND r.startDate < :endDate AND r.endDate > :startDate")
		List<Reservation> findOverlapping(@Param("vehicleId") Long vehicleId,
		                                   @Param("startDate") LocalDate startDate,
		                                   @Param("endDate") LocalDate endDate,
		                                   @Param("statuses") List<ReservationStatus> statuses);
	List<Reservation> findByCustomerId (Long customerId);
	List<Reservation> findByVehicleIdAndStatusIn (Long vehicleId,List<ReservationStatus> statuses);
	long countByStatus(ReservationStatus status);
}
