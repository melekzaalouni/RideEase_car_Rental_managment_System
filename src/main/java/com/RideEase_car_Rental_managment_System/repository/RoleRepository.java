package com.RideEase_car_Rental_managment_System.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.RideEase_car_Rental_managment_System.entity.Role;
import com.RideEase_car_Rental_managment_System.enumeration.RoleName;

public interface RoleRepository extends JpaRepository<Role, Long>{
Optional <Role> findById (Long id);
}
