package com.RideEase_car_Rental_managment_System.DTO;

import java.util.List;

public class PageResponseDTO<T> {
	private List<T>cintent ;
	private Long page ; 
	private Long size ; 
	private Long totalElemnts ;
	private Long totalPages ;
	
	public PageResponseDTO() {
		super();
	}
	public PageResponseDTO(List<T> cintent, Long page, Long size, Long totalElemnts, Long totalPages) {
	super();
		this.cintent = cintent;
		this.page = page;
		this.size = size;
		this.totalElemnts = totalElemnts;
		this.totalPages = totalPages;
	}
	public List<T> getCintent() {
		return cintent;
	}
	public void setCintent(List<T> cintent) {
		this.cintent = cintent;
	}
	public Long getPage() {
		return page;
	}
	public void setPage(Long page) {
		this.page = page;
	}
	public Long getSize() {
		return size;
	}
	public void setSize(Long size) {
		this.size = size;
	}
	public Long getTotalElemnts() {
		return totalElemnts;
	}
	public void setTotalElemnts(Long totalElemnts) {
		this.totalElemnts = totalElemnts;
	}
	public Long getTotalPages() {
		return totalPages;
	}
	public void setTotalPages(Long totalPages) {
		this.totalPages = totalPages;
	}
	
	
	
}
