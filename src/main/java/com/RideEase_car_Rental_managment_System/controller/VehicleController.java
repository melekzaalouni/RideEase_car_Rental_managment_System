package com.RideEase_car_Rental_managment_System.controller;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.ResponseEntity.BodyBuilder;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.RideEase_car_Rental_managment_System.DTO.VehicleRequestDTO;
import com.RideEase_car_Rental_managment_System.DTO.VehicleResponseDTO;
import com.RideEase_car_Rental_managment_System.enumeration.VehicleCategory;
import com.RideEase_car_Rental_managment_System.enumeration.VehicleStatus;
import com.RideEase_car_Rental_managment_System.service.VehicleService;
import jakarta.validation.Valid;
@RestController
@RequestMapping("/api/vehicles")
public class VehicleController {
	private final VehicleService vehicleService;
	public VehicleController(VehicleService vehicleService) {
		super();
		this.vehicleService = vehicleService;
	}
	@PostMapping
	public ResponseEntity<VehicleResponseDTO> createVehicle ( @Valid @RequestBody VehicleRequestDTO dto){
		VehicleResponseDTO createdVehicle = vehicleService.createVehicle(dto);
		return ResponseEntity.status(HttpStatus.CREATED).body(createdVehicle);
	}
	@GetMapping("/{id}")
	public ResponseEntity<VehicleResponseDTO> getVehicle (@PathVariable Long id){
		VehicleResponseDTO vehicle = vehicleService.getVehicleById(id);
		return ResponseEntity.status(HttpStatus.OK).body(vehicle);
	}
	@GetMapping
	public ResponseEntity<List<VehicleResponseDTO>> getVehicles (@RequestParam(required = false) VehicleCategory category,
	        @RequestParam(required = false) VehicleStatus status){
		List<VehicleResponseDTO> vehicles = vehicleService.getVehicles(category, status);
		return ResponseEntity.status(HttpStatus.OK).body(vehicles) ;
	}
	@PutMapping("/{id}")
	public ResponseEntity<VehicleResponseDTO> updateVehicle (@PathVariable Long id, @Valid @RequestBody VehicleRequestDTO dto){
		VehicleResponseDTO vehicle = vehicleService.updateVehicle(id, dto);
		return ResponseEntity.status(HttpStatus.OK).body(vehicle);
	}
	@DeleteMapping("/{id}")
	public ResponseEntity<Void> deleteVehicle (@PathVariable Long id){
		vehicleService.deleteVehicle(id);
		return ResponseEntity.noContent().build();
		
	}
	
	
		
}
