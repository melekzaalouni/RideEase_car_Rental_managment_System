package com.RideEase_car_Rental_managment_System.CustomExceptions;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.CONFLICT)
public class InvalidReservationStateException extends RuntimeException {
    public InvalidReservationStateException(String operation) {
        super("Cannot perform operation '" + operation );
    }
}
