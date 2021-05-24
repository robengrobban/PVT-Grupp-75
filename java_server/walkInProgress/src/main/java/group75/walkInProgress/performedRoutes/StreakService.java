package group75.walkInProgress.performedRoutes;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

import org.springframework.stereotype.Service;

@Service
public class StreakService {
	
	public List<Streak> getStreaks(List<PerformedRoute> routes) {
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

	public Streak getLongestStreak(List<PerformedRoute> userRoutes) {
		return getStreaks(userRoutes).stream().max(Comparator.comparing(v -> v.getDays())).orElse(null);
	}

}
