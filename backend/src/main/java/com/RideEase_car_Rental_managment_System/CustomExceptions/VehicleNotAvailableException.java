package com.RideEase_car_Rental_managment_System.CustomExceptions;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@SuppressWarnings("serial")
@ResponseStatus(HttpStatus.CONFLICT)
public class VehicleNotAvailableException extends RuntimeException{
	public VehicleNotAvailableException(String message) {
        super(message);
    }
}
