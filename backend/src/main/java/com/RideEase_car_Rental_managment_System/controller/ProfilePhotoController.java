package com.RideEase_car_Rental_managment_System.controller;

import java.util.Map;

import org.springframework.http.CacheControl;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.RideEase_car_Rental_managment_System.CustomExceptions.ResourceNotFoundException;
import com.RideEase_car_Rental_managment_System.entity.User;
import com.RideEase_car_Rental_managment_System.repository.UserRespository;
import com.RideEase_car_Rental_managment_System.service.FileStorageService;

/**
 * Profile picture of the logged-in user (admin, employee or customer).
 * Any authenticated user can manage THEIR OWN picture: the user is taken from the JWT.
 */
@RestController
@RequestMapping("/api/profile/photo")
public class ProfilePhotoController {

	private static final String FOLDER = "users";

	private final UserRespository userRepository;
	private final FileStorageService storage;

	public ProfilePhotoController(UserRespository userRepository, FileStorageService storage) {
		this.userRepository = userRepository;
		this.storage = storage;
	}

	private User current(Authentication authentication) {
		return userRepository.findByUsername(authentication.getName())
				.orElseThrow(() -> new ResourceNotFoundException("user not found"));
	}

	@GetMapping
	public ResponseEntity<byte[]> get(Authentication authentication) {
		User user = current(authentication);
		if (user.getPhotoFile() == null) {
			return ResponseEntity.notFound().build();
		}
		byte[] data = storage.read(FOLDER, user.getPhotoFile());
		return ResponseEntity.ok()
				.contentType(MediaType.parseMediaType(FileStorageService.contentType(user.getPhotoFile())))
				.cacheControl(CacheControl.noCache())
				.body(data);
	}

	@PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
	public ResponseEntity<Map<String, Object>> upload(@RequestParam("file") MultipartFile file,
			Authentication authentication) {
		User user = current(authentication);
		String newFile = storage.storeImage(FOLDER, "user-" + user.getId(), file);
		String oldFile = user.getPhotoFile();
		user.setPhotoFile(newFile);
		userRepository.save(user);
		storage.delete(FOLDER, oldFile);
		return ResponseEntity.ok(Map.of("photoUrl", "/api/profile/photo?v=" + newFile));
	}

	@DeleteMapping
	public ResponseEntity<Void> remove(Authentication authentication) {
		User user = current(authentication);
		String oldFile = user.getPhotoFile();
		user.setPhotoFile(null);
		userRepository.save(user);
		storage.delete(FOLDER, oldFile);
		return ResponseEntity.noContent().build();
	}
}
