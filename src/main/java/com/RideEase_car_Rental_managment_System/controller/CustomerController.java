package com.RideEase_car_Rental_managment_System.controller;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.ResponseEntity.BodyBuilder;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.RideEase_car_Rental_managment_System.DTO.CustomerRequestDTO;
import com.RideEase_car_Rental_managment_System.DTO.CustomerResponseDTO;
import com.RideEase_car_Rental_managment_System.service.CustomerService;
import jakarta.validation.Valid;
@RestController 
@RequestMapping("/api/customers")
public class CustomerController {
	private final CustomerService customerService ;
	public CustomerController(CustomerService customerService) {
		super();
		this.customerService = customerService;
	}
	
	@GetMapping("/{id}")
	public ResponseEntity<CustomerResponseDTO> getCustomer(@PathVariable Long id ,  Authentication authentication ){
		CustomerResponseDTO getCustomerById = customerService.getCustomerById(id, authentication);
		return ResponseEntity.status(HttpStatus.OK).body(getCustomerById);
	}
	@PreAuthorize("hasAnyRole('ADMIN', 'EMPLOYEE')")
	@GetMapping 
	public ResponseEntity<List<CustomerResponseDTO>> listCustomers (){
		List<CustomerResponseDTO> customers = customerService.getAllCustomers();	
		return ResponseEntity.status(HttpStatus.OK).body(customers) ;
	}
	@PutMapping("/{id}")
	public ResponseEntity<CustomerResponseDTO> updateCustomer (@PathVariable Long id ,  @RequestBody @Valid CustomerRequestDTO dto,  Authentication authentication){
		CustomerResponseDTO customer = customerService.updateCustomer(id, dto, authentication);
		return ResponseEntity.status(HttpStatus.OK).body(customer);
	}
	@PreAuthorize("hasRole('ADMIN') or @securityService.isOwner(#id, authentication)")
	@DeleteMapping("/{id}")
	public BodyBuilder deleteCustomer (@PathVariable Long id,Authentication authentication){
	    customerService.deleteCustomer(id, authentication);
		return ResponseEntity.status(HttpStatus.NO_CONTENT);
		
	}

}
