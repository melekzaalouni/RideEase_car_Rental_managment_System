package com.RideEase_car_Rental_managment_System.CustomExceptions;

public class DuplicateResourceException extends RuntimeException {
	public DuplicateResourceException(String message) {
        super(message);
    }
}
