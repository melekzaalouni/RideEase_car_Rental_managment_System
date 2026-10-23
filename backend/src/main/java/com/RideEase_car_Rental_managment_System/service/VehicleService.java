package com.RideEase_car_Rental_managment_System.service;
import java.util.ArrayList;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.RideEase_car_Rental_managment_System.CustomExceptions.DuplicateResourceException;
import com.RideEase_car_Rental_managment_System.CustomExceptions.ResourceNotFoundException;
import com.RideEase_car_Rental_managment_System.DTO.VehicleRequestDTO;
import com.RideEase_car_Rental_managment_System.DTO.VehicleResponseDTO;
import com.RideEase_car_Rental_managment_System.entity.Vehicle;
import com.RideEase_car_Rental_managment_System.enumeration.VehicleCategory;
import com.RideEase_car_Rental_managment_System.enumeration.VehicleStatus;
import com.RideEase_car_Rental_managment_System.repository.VehicleRepository;
import org.springframework.web.multipart.MultipartFile;

@Service
public class VehicleService {
	@Autowired
	private VehicleRepository vehicleRepository ;
	@Autowired
	private FileStorageService storage ;
	private static final String PHOTO_FOLDER = "vehicles";
	
	public VehicleService() {
		super();
	}
	public VehicleService(VehicleRepository vehicleRepository) {
		super();
		this.vehicleRepository = vehicleRepository;
	}
	public VehicleResponseDTO createVehicle(VehicleRequestDTO dto ) {
		if(vehicleRepository.existsByLicensePlate(dto.getLicensePlate())) {
			throw new DuplicateResourceException("LicensePlate existe");
		};
		Vehicle vehicle = new Vehicle(); 
		vehicle.setLicensePlate(dto.getLicensePlate());
		vehicle.setBrand(dto.getBrand());
		vehicle.setModel(dto.getModel());
		vehicle.setCategory(dto.getCategory());
		vehicle.setDailyRate(dto.getDailyRate());
		vehicle.setYearOfManufacture(dto.getYearOfManufacture());
		vehicle.setStatus(VehicleStatus.AVAILABLE);
		vehicle.setVersion(dto.getVersion());
		return convertToResponseDTO(vehicleRepository.save(vehicle));
	}
	public VehicleResponseDTO getVehicleById(Long id) {
		Vehicle vehicle = vehicleRepository.findById(id).orElseThrow(()-> new ResourceNotFoundException("vehicle not found"));
		return convertToResponseDTO(vehicle);
	}
	public List<VehicleResponseDTO> getVehicles(VehicleCategory category, VehicleStatus status) {
		List<Vehicle> vehicles = vehicleRepository.findByCategoryAndStatus(category, status);
		List<VehicleResponseDTO> responses = new ArrayList<>();
		for (Vehicle vehicle : vehicles) {
			responses.add(convertToResponseDTO(vehicle));
		}
		return responses ;
	}
	public VehicleResponseDTO updateVehicle(Long id, VehicleRequestDTO dto) {
		if(vehicleRepository.existsByLicensePlateAndIdNot(dto.getLicensePlate(), id)) {
			throw new DuplicateResourceException("licencePlate existe !");
		}
		Vehicle vehicle = vehicleRepository.findById(id).orElseThrow(()-> new ResourceNotFoundException("vehicle not found"));
		vehicle.setLicensePlate(dto.getLicensePlate());
		vehicle.setBrand(dto.getBrand());
		vehicle.setModel(dto.getModel());
		vehicle.setCategory(dto.getCategory());
		vehicle.setDailyRate(dto.getDailyRate());
		vehicle.setYearOfManufacture(dto.getYearOfManufacture());
		vehicle.setVersion(dto.getVersion());
		return convertToResponseDTO(vehicleRepository.save(vehicle));
	}
	public void deleteVehicle(Long id) {
		Vehicle vehicle = vehicleRepository.findById(id).orElseThrow(()-> new ResourceNotFoundException("vehicle not found"));
		vehicleRepository.delete(vehicle);
		storage.delete(PHOTO_FOLDER, vehicle.getPhotoFile());
	}
	/** Replaces the picture of a vehicle. Updating the other fields never touches it. */
	public VehicleResponseDTO setPhoto(Long id, MultipartFile file) {
		Vehicle vehicle = vehicleRepository.findById(id).orElseThrow(()-> new ResourceNotFoundException("vehicle not found"));
		String newFile = storage.storeImage(PHOTO_FOLDER, "vehicle-" + id, file);
		String oldFile = vehicle.getPhotoFile();
		vehicle.setPhotoFile(newFile);
		Vehicle saved = vehicleRepository.save(vehicle);
		storage.delete(PHOTO_FOLDER, oldFile);
		return convertToResponseDTO(saved);
	}
	/** Goes back to the default picture. */
	public VehicleResponseDTO removePhoto(Long id) {
		Vehicle vehicle = vehicleRepository.findById(id).orElseThrow(()-> new ResourceNotFoundException("vehicle not found"));
		String oldFile = vehicle.getPhotoFile();
		vehicle.setPhotoFile(null);
		Vehicle saved = vehicleRepository.save(vehicle);
		storage.delete(PHOTO_FOLDER, oldFile);
		return convertToResponseDTO(saved);
	}
	public String getPhotoFileName(Long id) {
		Vehicle vehicle = vehicleRepository.findById(id).orElseThrow(()-> new ResourceNotFoundException("vehicle not found"));
		if (vehicle.getPhotoFile() == null) {
			throw new ResourceNotFoundException("this vehicle has no uploaded photo");
		}
		return vehicle.getPhotoFile();
	}
	public byte[] readPhoto(String fileName) {
		return storage.read(PHOTO_FOLDER, fileName);
	}
	private VehicleResponseDTO convertToResponseDTO(Vehicle vehicle) {
		VehicleResponseDTO dto = new VehicleResponseDTO();
	    dto.setId(vehicle.getId());
	    dto.setLicensePlate(vehicle.getLicensePlate());
	    dto.setBrand(vehicle.getBrand());
	    dto.setModel(vehicle.getModel());
	    dto.setCategory(vehicle.getCategory());
	    dto.setDailyRate(vehicle.getDailyRate());
	    dto.setYearOfManufacture(vehicle.getYearOfManufacture());
	    dto.setStatus(vehicle.getStatus());
	    dto.setVersion(vehicle.getVersion());
	    if (vehicle.getPhotoFile() != null) {
	    	dto.setPhotoUrl("/api/vehicles/" + vehicle.getId() + "/photo?v=" + vehicle.getPhotoFile());
	    }
	    return dto;
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

}
