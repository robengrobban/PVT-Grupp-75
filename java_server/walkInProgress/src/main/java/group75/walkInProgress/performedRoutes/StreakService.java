package group75.walkInProgress.performedRoutes;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class StreakService {
	@Autowired
	  private PerformedRouteRepository performedRouteRepository;
	
	public List<Streak> getStreaks(int userId) {
		List<PerformedRoute> routes = performedRouteRepository.findByUserIdOrderByTimeFinishedAsc(userId);
		List<Streak> streaks = new ArrayList<>();
		
		LocalDate startDate = null;
		int streakCount = 0;
		LocalDate previousDate = null;
		List<PerformedRoute> currentStreak = new ArrayList<>();
		
		for (PerformedRoute route : routes) {
			if(previousDate == null) {
				streakCount++;
				currentStreak.add(route);
				startDate = route.getTimeFinished().toLocalDate();
			} else if(route.getTimeFinished().toLocalDate().equals(previousDate)){
				//Date is the same, add to streak but don't increase count
				currentStreak.add(route);
			} else if(route.getTimeFinished().toLocalDate().equals(previousDate.plusDays(1))) {
				//we have found a consecutive day
				streakCount++;
				currentStreak.add(route);
			} else {
				//The streak is broken
				if(streakCount>1) {
					streaks.add(new Streak(streakCount, startDate, previousDate, new ArrayList<>(currentStreak)));
				}
				//start a new streak with currentRoute as the only member
				streakCount=1;
				currentStreak.clear();
				currentStreak.add(route);
				startDate = route.getTimeFinished().toLocalDate();
			}
			previousDate = route.getTimeFinished().toLocalDate();
		}
		if(streakCount>1) {
			streaks.add(new Streak(streakCount, startDate, previousDate, currentStreak));
		}
		
		return streaks;
	}

	public Streak getLongestStreak(int userId) {
		return getStreaks(userId).stream().max(Comparator.comparing(v -> v.getDays())).orElse(null);
	}
	
	public Streak getCurrentStreak(int userId) {
		LocalDateTime beginningOfDay = LocalDateTime.of(LocalDate.now(), LocalTime.MIN);
		LocalDateTime endOfDay = LocalDateTime.of(LocalDate.now(), LocalTime.MAX);
		boolean streakIsBroken = false;
		int streakCount = 0;
		List<PerformedRoute> routes = new ArrayList<PerformedRoute>();
		
		//add today if any
		List<PerformedRoute> foundRoutes = performedRouteRepository.findByUserIdAndTimeFinishedBetween(userId, beginningOfDay, endOfDay);
		if(!foundRoutes.isEmpty()) {
			streakCount++;
			routes.addAll(foundRoutes);
		}
		
		//check if we had a streak before today
		while(!streakIsBroken) {
			beginningOfDay = beginningOfDay.minusDays(1);
			endOfDay = endOfDay.minusDays(1);
			foundRoutes = performedRouteRepository.findByUserIdAndTimeFinishedBetween(userId, beginningOfDay, endOfDay);
			if(foundRoutes.isEmpty()) {
				streakIsBroken = true;
			} else {
				streakCount++;
				routes.addAll(foundRoutes);
			}
		}
		if(routes.isEmpty())
			return null;
		
		routes.sort((a,b)->b.getTimeFinished().compareTo(a.getTimeFinished()));
		return new Streak(streakCount, routes.get(routes.size()-1).getTimeFinished().toLocalDate(),routes.get(0).getTimeFinished().toLocalDate(), routes);
	}

}
