package com.RideEase_car_Rental_managment_System.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.RideEase_car_Rental_managment_System.entity.Customer;
@Repository
public interface  CustumerRepository extends JpaRepository<Customer , Long >{
	Optional<Customer>findByEmail(String email);
	Optional<Customer>findBydriverLicenseNumber(String driverLicenseNumber);
	boolean existsByEmail(String email);

}
