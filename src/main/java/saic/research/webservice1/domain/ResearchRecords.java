package saic.research.webservice1.domain;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.NamedQuery;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

@Entity
@Table(name = "RESEARCH_RECORDS")
@SequenceGenerator(name="Recordseq", initialValue=1, allocationSize=100)
@NamedQuery(name="ResearchRecords.findAll", query="SELECT r FROM ResearchRecords r")
public class ResearchRecords {
		
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name="id")
	private Integer id;
	
	@Column(name="title" , nullable = false)
	private String title;
	
	@Temporal(TemporalType.DATE)
	@Column(name="record_date")
	private Date recordDate;
	
	@Column(name="status")
	private String status;
	
	@Column(name="findings")
	private String findings;
	
	public ResearchRecords(String title, Date recordDate, String status, String findings) {
		super();
		this.title = title;
		this.recordDate = recordDate;
		this.status = status;
		this.findings = findings;
	}

	public ResearchRecords() {
		super();
	}
	
	/**
	 * @return the id
	 */
	public Integer getId() {
		return id;
	}

	/**
	 * @param id the id to set
	 */
	public void setId(Integer id) {
		this.id = id;
	}

	/**
	 * @return the title
	 */
	public String getTitle() {
		return title;
	}

	/**
	 * @param title the title to set
	 */
	public void setTitle(String title) {
		this.title = title;
	}

	/**
	 * @return the recordDate
	 */
	public Date getRecordDate() {
		return recordDate;
	}

	/**
	 * @param recordDate the recordDate to set
	 */
	public void setRecordDate(Date recordDate) {
		this.recordDate = recordDate;
	}

	/**
	 * @return the status
	 */
	public String getStatus() {
		return status;
	}

	/**
	 * @param status the status to set
	 */
	public void setStatus(String status) {
		this.status = status;
	}

	/**
	 * @return the findings
	 */
	public String getFindings() {
		return findings;
	}

	/**
	 * @param findings the findings to set
	 */
	public void setFindings(String findings) {
		this.findings = findings;
	}
}
