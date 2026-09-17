package com.RideEase_car_Rental_managment_System.entity;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
@Entity
@Table(name="users" , uniqueConstraints = {
		@UniqueConstraint(columnNames ="username"),
		@UniqueConstraint(columnNames ="email")
})
public class User {
	@Id 
	@GeneratedValue
	@Column(name="user_id")
	private Long id ;
	@Column(nullable = false, unique = true, length = 60)
	private String username ;
	@Column(nullable = false, unique = true, length = 120)
	private String email ;
	@Column(name="password_hash",nullable = false, length = 255)
	private String passwordHash ;
	@Column(name="enabled",nullable = false)
	private boolean enabled=true ;
	@Column(name="created_at", nullable = false)
	private LocalDateTime createdAt ;
	@OneToOne
	@JoinColumn(name="customer_id")

	private Customer customer ;
	@ManyToMany(fetch=FetchType.EAGER)
	@JoinTable(
			name="user_roles",
			joinColumns = @JoinColumn(name="user_id"),
			inverseJoinColumns = @JoinColumn(name="role_id")
			)
	
	private Set<Role> roles = new HashSet<>();
	
	public User() {
		super();
	}
	public User(Long id, String username, String email, String passwordHash, boolean enabled, LocalDateTime createdAt,
			Customer customer, Set<Role> roles) {
		super();
		this.id = id;
		this.username = username;
		this.email = email;
		this.passwordHash = passwordHash;
		this.enabled = enabled;
		this.createdAt = createdAt;
		this.customer = customer;
		this.roles = roles;
	}
	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}
	public String getUsername() {
		return username;
	}
	public void setUsername(String username) {
		this.username = username;
	}
	public String getEmail() {
		return email;
	}
	public void setEmail(String email) {
		this.email = email;
	}
	public String getPasswordHash() {
		return passwordHash;
	}
	public void setPasswordHash(String passwordHash) {
		this.passwordHash = passwordHash;
	}
	public boolean isEnabled() {
		return enabled;
	}
	public void setEnabled(boolean enabled) {
		this.enabled = enabled;
	}
	public LocalDateTime getCreatedAt() {
		return createdAt;
	}
	public void setCreatedAt(LocalDateTime createdAt) {
		this.createdAt = createdAt;
	}
	public Customer getCustomer() {
		return customer;
	}
	
	public void setCustomer(Customer customer) {
		this.customer = customer;
	}
	public Set<Role> getRoles() {
		return roles;
	}
	public void setRoles(Set<Role> roles) {
		this.roles = roles;
	}
	
	
	
	
}
