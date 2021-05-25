package group75.walkInProgress.performedRoutes;


import java.util.List;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;


public interface PerformedRouteRepository  extends CrudRepository<PerformedRoute, Integer>{
	
	PerformedRoute findTopByUserIdOrderByDistanceDesc(int userId);
	
	PerformedRoute findTopByUserIdOrderByActualDurationDesc(int userId);

	List<PerformedRoute> findByUserId(int userId);

	List<PerformedRoute> findByUserIdOrderByTimeFinishedAsc(int userId);
	
	List<PerformedRoute> findByUserIdOrderByTimeFinishedDesc(int userId);

	@Query("SELECT SUM(r.actualDuration) FROM PerformedRoute r WHERE r.userId = ?1")
	Integer findTotalTimeByUserId(int userId);
	
	@Query("SELECT SUM(r.distance) FROM PerformedRoute r WHERE r.userId = ?1")
	Integer findTotalDistanceByUserId(int userId);
}
