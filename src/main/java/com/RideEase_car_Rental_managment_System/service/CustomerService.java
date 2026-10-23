package com.RideEase_car_Rental_managment_System.service;
import java.util.ArrayList;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

import com.RideEase_car_Rental_managment_System.CustomExceptions.DuplicateResourceException;
import com.RideEase_car_Rental_managment_System.CustomExceptions.ResourceNotFoundException;
import com.RideEase_car_Rental_managment_System.DTO.CustomerRequestDTO;
import com.RideEase_car_Rental_managment_System.DTO.CustomerResponseDTO;
import com.RideEase_car_Rental_managment_System.entity.Customer;
import com.RideEase_car_Rental_managment_System.repository.CustumerRepository;


@Service
public class CustomerService {
	@Autowired 
	private CustumerRepository customerRepository;
	
	public CustomerService() {
		super();
	}

	public CustomerService(CustumerRepository customerRepository) {
		super();
		this.customerRepository = customerRepository;
	}
	/*
	public CustomerResponseDTO createCustomer (CustomerRequestDTO dto) {
		if(customerRepository.existsByEmail(dto.getEmail())) {
			throw new RuntimeException("email already found");
		}
		if(customerRepository.findBydriverLicenseNumber(dto.getDriverLicenseNumber()).isPresent()) {
			throw new RuntimeException("driver licence already found ");
		}
		Customer customer = new Customer();
		customer.setUsername(dto.getUsername());
		customer.setFirstName(dto.getFirstName());
		customer.setLastName(dto.getLastName());
		customer.setEmail(dto.getEmail());
		customer.setPhoneNumber(dto.getPhoneNumber());
		customer.setDriverLicenseNumber(dto.getDriverLicenseNumber());
		customer.setRegistrationDate(LocalDate.now());
		return convertToResponseDTO(customerRepository.save(customer));
	}*/
	public CustomerResponseDTO getCustomerById (Long id ,  Authentication authentication) {
		checkOwnership(id, authentication);

		Customer customer = customerRepository.findById(id)
		            .orElseThrow(() -> new RuntimeException("Customer not found"));

		return convertToResponseDTO(customer);
	}
	public List<CustomerResponseDTO> getAllCustomers(){
		List<Customer> customers=customerRepository.findAll();
		List <CustomerResponseDTO> responses = new ArrayList<>();
		for(Customer customer : customers) {
			responses.add(convertToResponseDTO(customer));
		}
		return responses;
	}
	
	public CustomerResponseDTO updateCustomer(Long id, CustomerRequestDTO dto,Authentication authentication) {
		 
		checkOwnership(id, authentication);
	    customerRepository.findByEmail(dto.getEmail())
        .ifPresent(existingCustomer -> {
            if (!existingCustomer.getId().equals(id)) {
                throw new DuplicateResourceException("Email already exists");
            }
        });
	    customerRepository.findBydriverLicenseNumber(dto.getDriverLicenseNumber())
        .ifPresent(existingCustomer -> {
            if (!existingCustomer.getId().equals(id)) {
                throw new DuplicateResourceException("Driver license already exists");
            }
        });
	    Customer customer = customerRepository.findById(id).orElseThrow(()-> new ResourceNotFoundException("user not found"));
		customer.setFirstName(dto.getFirstName());
		customer.setLastName(dto.getLastName());
		customer.setEmail(dto.getEmail());
		customer.setDriverLicenseNumber(dto.getDriverLicenseNumber());
		customer.setPhoneNumber(dto.getPhoneNumber());
		return convertToResponseDTO(customerRepository.save(customer));
	}
	public void deleteCustomer (Long id,Authentication authentication ) {
		
		checkOwnership(id, authentication);
		Customer customer =customerRepository.findById(id).orElseThrow(()-> new ResourceNotFoundException("user not found"));
		customerRepository.delete(customer);
		
	}
	private void checkOwnership(Long customerId, Authentication authentication) {

	    String username = authentication.getName();

	    Customer customer = customerRepository.findById(customerId)
	            .orElseThrow(() -> new RuntimeException("Customer not found"));

	    boolean isAdmin = authentication.getAuthorities().stream()
	            .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));

	    boolean isEmployee = authentication.getAuthorities().stream()
	            .anyMatch(a -> a.getAuthority().equals("ROLE_EMPLOYEE"));

	    if (!isAdmin && !isEmployee &&
	            !customer.getUsername().equals(username)) {

	        throw new AccessDeniedException("You can only access your own account");
	    }
	}
	private CustomerResponseDTO convertToResponseDTO(Customer customer) {
	    CustomerResponseDTO dto = new CustomerResponseDTO();
	    dto.setId(customer.getId());
	    dto.setFirstName(customer.getFirstName());
	    dto.setLastName(customer.getLastName());
	    dto.setEmail(customer.getEmail());
	    dto.setPhoneNumber(customer.getPhoneNumber());
	    dto.setDriverLicenseNumber(customer.getDriverLicenseNumber());
	    dto.setRegistrationDate(customer.getRegistrationDate());

	    return dto;
	}



	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}
