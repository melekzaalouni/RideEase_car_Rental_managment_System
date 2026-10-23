package com.RideEase_car_Rental_managment_System.entity;

import java.time.LocalDateTime;

import org.springframework.data.annotation.CreatedBy;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedBy;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import jakarta.persistence.Column;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.MappedSuperclass;
@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
public class Auditable {
	@CreatedDate
	@Column(name="created_at_audit" , updatable = false)
	private LocalDateTime createdAtAudit ; 
	@LastModifiedDate
	@Column(name="update_at")
	private LocalDateTime updatedAt ; 
	
	@LastModifiedBy 
	@Column(name="updated_By")
	private String updateBy;
	public LocalDateTime getCreatedAtAudit() {
		return createdAtAudit;
	}
	public void setCreatedAtAudit(LocalDateTime createdAtAudit) {
		this.createdAtAudit = createdAtAudit;
	}
	public LocalDateTime getUpdatedAt() {
		return updatedAt;
	}
	public void setUpdatedAt(LocalDateTime updatedAt) {
		this.updatedAt = updatedAt;
	}
	
	public String getUpdateBy() {
		return updateBy;
	}
	public void setUpdateBy(String updateBy) {
		this.updateBy = updateBy;
	}
	
}
