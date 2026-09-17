package com.RideEase_car_Rental_managment_System.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

import com.RideEase_car_Rental_managment_System.entity.Vehicle;
import com.RideEase_car_Rental_managment_System.enumeration.VehicleCategory;
import com.RideEase_car_Rental_managment_System.enumeration.VehicleStatus;

public interface VehicleRepository extends
JpaRepository<Vehicle , Long > ,
JpaSpecificationExecutor<Vehicle>{
	boolean existsByLicensePlateAndIdNot(String licensePlate, Long id);
	List<Vehicle>findByStatus (VehicleStatus status);
	List<Vehicle>findByCategoryAndStatus(VehicleCategory category,
			VehicleStatus status);
	boolean existsByLicensePlate(String licensePlate);
	long countByStatus(VehicleStatus status);
}
