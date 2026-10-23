package com.RideEase_car_Rental_managment_System.controller;
import java.util.List;

import org.springframework.http.CacheControl;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.multipart.MultipartFile;
import java.util.concurrent.TimeUnit;
import com.RideEase_car_Rental_managment_System.service.FileStorageService;
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
	// ---- photo: GET is public (see SecurityConfig), POST / DELETE are ADMIN + EMPLOYEE ----
	@PostMapping(value = "/{id}/photo", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
	public ResponseEntity<VehicleResponseDTO> uploadPhoto(@PathVariable Long id, @RequestParam("file") MultipartFile file){
		return ResponseEntity.ok(vehicleService.setPhoto(id, file));
	}
	@DeleteMapping("/{id}/photo")
	public ResponseEntity<VehicleResponseDTO> deletePhoto(@PathVariable Long id){
		return ResponseEntity.ok(vehicleService.removePhoto(id));
	}
	@GetMapping("/{id}/photo")
	public ResponseEntity<byte[]> getPhoto(@PathVariable Long id){
		String fileName = vehicleService.getPhotoFileName(id);
		byte[] data = vehicleService.readPhoto(fileName);
		// the URL carries ?v=<file name>, so a new upload always gets a new URL: the picture can be cached for long
		return ResponseEntity.ok()
				.contentType(MediaType.parseMediaType(FileStorageService.contentType(fileName)))
				.cacheControl(CacheControl.maxAge(30, TimeUnit.DAYS).cachePublic())
				.body(data);
	}
	@DeleteMapping("/{id}")
	public ResponseEntity<Void> deleteVehicle (@PathVariable Long id){
		vehicleService.deleteVehicle(id);
		return ResponseEntity.noContent().build();
		
	}
	
	
		
}
