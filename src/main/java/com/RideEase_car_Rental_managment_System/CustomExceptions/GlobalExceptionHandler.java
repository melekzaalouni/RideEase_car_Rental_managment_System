package com.RideEase_car_Rental_managment_System.CustomExceptions;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

    // 1. 404 NOT FOUND -> ResourceNotFoundException
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<Map<String, Object>> handleNotFound(ResourceNotFoundException ex) {
        return buildError(HttpStatus.NOT_FOUND, ex.getMessage());
    }

    // 2. 409 CONFLICT -> VehicleNotAvailableException
    @ExceptionHandler(VehicleNotAvailableException.class)
    public ResponseEntity<Map<String, Object>> handleVehicleNotAvailable(VehicleNotAvailableException ex) {
        return buildError(HttpStatus.CONFLICT, ex.getMessage());
    }

    // 3. 400 BAD REQUEST -> InvalidReservationDateException
    @ExceptionHandler(InvalidReservationDateException.class)
    public ResponseEntity<Map<String, Object>> handleInvalidDate(InvalidReservationDateException ex) {
        return buildError(HttpStatus.BAD_REQUEST, ex.getMessage());
    }

    // 4. 409 CONFLICT -> InvalidReservationStateException
    @ExceptionHandler(InvalidReservationStateException.class)
    public ResponseEntity<Map<String, Object>> handleInvalidState(InvalidReservationStateException ex) {
        return buildError(HttpStatus.CONFLICT, ex.getMessage());
    }

    // 5. 400 BAD REQUEST -> PaymentMismatchException
    @ExceptionHandler(PaymentMismatchException.class)
    public ResponseEntity<Map<String, Object>> handlePaymentMismatch(PaymentMismatchException ex) {
        return buildError(HttpStatus.BAD_REQUEST, ex.getMessage());
    }

    // 6. 400 BAD REQUEST -> MethodArgumentNotValidException (Validation Errors)
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> handleValidationErrors(MethodArgumentNotValidException ex) {
        List<String> errors = ex.getBindingResult()
                .getFieldErrors()
                .stream()
                .map(error -> error.getField() + ": " + error.getDefaultMessage())
                .collect(Collectors.toList());

        Map<String, Object> body = new HashMap<>();
        body.put("timestamp", LocalDateTime.now());
        body.put("status", 400);
        body.put("fieldErrors", errors);

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(body);
    }
    @ExceptionHandler(DuplicateResourceException.class)
    public ResponseEntity<Map<String, Object>> handleDuplicate(DuplicateResourceException ex) {
        return buildError(HttpStatus.CONFLICT, ex.getMessage());
    }

    // Helper method for standard errors (timestamp, status, error, message)
    private ResponseEntity<Map<String, Object>> buildError(HttpStatus status, String message) {
        Map<String, Object> body = new HashMap<>();
        body.put("timestamp", LocalDateTime.now());
        body.put("status", status.value());
        body.put("error", status.getReasonPhrase());
        body.put("message", message);

        return ResponseEntity.status(status).body(body);
    }
}