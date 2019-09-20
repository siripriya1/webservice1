package saic.research.webservice1.repository;

import java.util.Date;
import java.util.List;

import org.springframework.transaction.annotation.Transactional;

import saic.research.webservice1.domain.ResearchRecords;

public interface ResearchRecordsRepository extends BaseRepository<ResearchRecords, Integer> {		 
	@Transactional
	 void deleteById(Integer id);
	
	@Transactional
	ResearchRecords findById(Integer id);
	
	@Transactional
	List<ResearchRecords> findAll();
	
}
