package com.RideEase_car_Rental_managment_System.CustomExceptions;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@SuppressWarnings("serial")
@ResponseStatus(HttpStatus.BAD_REQUEST)
public class PaymentMismatchException extends RuntimeException{
	public PaymentMismatchException(String message) {
        super(message);
    }
}
