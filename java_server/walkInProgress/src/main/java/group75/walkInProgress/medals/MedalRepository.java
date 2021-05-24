package group75.walkInProgress.medals;

import java.util.List;

import org.springframework.data.repository.CrudRepository;


public interface MedalRepository extends CrudRepository<Medal, Integer>{

	List<Medal> findByUserId(int uderId);

}
