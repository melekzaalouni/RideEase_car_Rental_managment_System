package com.RideEase_car_Rental_managment_System.service;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Locale;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.RideEase_car_Rental_managment_System.CustomExceptions.InvalidImageException;
import com.RideEase_car_Rental_managment_System.CustomExceptions.ResourceNotFoundException;

/**
 * Stores uploaded pictures (vehicle photos, profile photos) on disk.
 * The database only keeps the generated file name.
 */
@Service
public class FileStorageService {

	public static final long MAX_BYTES = 5L * 1024 * 1024;

	private final Path root;

	public FileStorageService(@Value("${app.upload-dir:uploads}") String uploadDir) {
		this.root = Paths.get(uploadDir).toAbsolutePath().normalize();
		try {
			Files.createDirectories(root);
		} catch (IOException e) {
			throw new UncheckedIOException(e);
		}
	}

	/** Validates the image (real content, not just the extension) and saves it. Returns the new file name. */
	public String storeImage(String folder, String prefix, MultipartFile file) {
		if (file == null || file.isEmpty()) {
			throw new InvalidImageException("No image received");
		}
		if (file.getSize() > MAX_BYTES) {
			throw new InvalidImageException("Image is too large (max 5 MB)");
		}
		byte[] data;
		try {
			data = file.getBytes();
		} catch (IOException e) {
			throw new UncheckedIOException(e);
		}
		String ext = detectExtension(data);
		if (ext == null) {
			throw new InvalidImageException("Only JPEG, PNG or WEBP images are accepted");
		}
		String name = prefix + "-" + UUID.randomUUID().toString().replace("-", "") + ext;
		try {
			Path dir = root.resolve(folder).normalize();
			Files.createDirectories(dir);
			Files.write(dir.resolve(name), data);
		} catch (IOException e) {
			throw new UncheckedIOException(e);
		}
		return name;
	}

	public byte[] read(String folder, String filename) {
		Path p = resolve(folder, filename);
		if (!Files.isRegularFile(p)) {
			throw new ResourceNotFoundException("photo not found");
		}
		try {
			return Files.readAllBytes(p);
		} catch (IOException e) {
			throw new UncheckedIOException(e);
		}
	}

	/** Silently ignores a null name or a file that is already gone. */
	public void delete(String folder, String filename) {
		if (filename == null || filename.isBlank()) {
			return;
		}
		try {
			Files.deleteIfExists(resolve(folder, filename));
		} catch (IOException | RuntimeException ignored) {
			// nothing to do: an orphan file is harmless
		}
	}

	public static String contentType(String filename) {
		String f = filename == null ? "" : filename.toLowerCase(Locale.ROOT);
		if (f.endsWith(".png")) return "image/png";
		if (f.endsWith(".webp")) return "image/webp";
		return "image/jpeg";
	}

	private Path resolve(String folder, String filename) {
		Path dir = root.resolve(folder).normalize();
		Path p = dir.resolve(filename).normalize();
		if (!p.startsWith(dir)) {
			throw new ResourceNotFoundException("photo not found");
		}
		return p;
	}

	private static String detectExtension(byte[] d) {
		if (d.length >= 3 && (d[0] & 0xFF) == 0xFF && (d[1] & 0xFF) == 0xD8 && (d[2] & 0xFF) == 0xFF) {
			return ".jpg";
		}
		if (d.length >= 8 && (d[0] & 0xFF) == 0x89 && d[1] == 'P' && d[2] == 'N' && d[3] == 'G') {
			return ".png";
		}
		if (d.length >= 12 && d[0] == 'R' && d[1] == 'I' && d[2] == 'F' && d[3] == 'F'
				&& d[8] == 'W' && d[9] == 'E' && d[10] == 'B' && d[11] == 'P') {
			return ".webp";
		}
		return null;
	}
}
