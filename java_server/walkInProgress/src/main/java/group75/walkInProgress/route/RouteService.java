package group75.walkInProgress.route;

import java.io.IOException;
import org.springframework.stereotype.Service;
import com.google.maps.errors.ApiException;
import com.google.maps.model.LatLng;

@Service
public class RouteService implements IRouteService {
	

	private static final int MAXIMUM_NUMBER_OF_TRIES = 10;

	private static final int SECONDS_PER_MINUTE = 60;
	
	private static final int ACCEPTABLE_DURATION_DIFFERENCE_IN_MINUTES = 10;
	
	

	@Override
	public Route getRoute(LatLng startPoint, double durationInMinutes, double radians, String type) throws ApiException, InterruptedException, IOException, RouteException, TypeException {
		if(startPoint == null) {
			throw new IllegalArgumentException("StartPoint can't be null");
		}
		if (durationInMinutes < 0) {
			throw new IllegalArgumentException("Duration can't be negative");
		}
		RouteGenerator generator = getRouteGenerator(startPoint, durationInMinutes, radians, type);
		if(type != null) {
			generator.setTypeOfInterest(type);
		}
		
		return findRoute(generator, durationInMinutes);

	}
	
	private Route findRoute(RouteGenerator generator, Double durationInMinutes) throws ApiException, InterruptedException, IOException, RouteException{
		while (generator.getNumberOfTries() < getMaximumNumberOfTries()) {
			
			Route route = generator.tryToFindRoute();
			
			if(isWithinAcceptedTime(route, durationInMinutes)) {
				return route;
			}else if (isUnderAcceptedTime(route, durationInMinutes)){
				generator.increaseCrowFactor();
			} else {
				generator.decreaseCrowFactor();
			}
		}
		return null;
	}
	
	RouteGenerator getRouteGenerator(LatLng startPoint, double durationInMinutes, double radians, String type) {
		return new RouteGenerator(startPoint, durationInMinutes, radians);
	}
	
	boolean isWithinAcceptedTime(Route route, double durationInMinutes ) {
		if(durationInMinutes < 0) {
			throw new IllegalArgumentException("Duration can't be negative");
		}
		if(route == null) {
			throw new IllegalArgumentException("Route can't be null");
		}
		return Math.abs(route.getDurationInSeconds()/SECONDS_PER_MINUTE - durationInMinutes) <= ACCEPTABLE_DURATION_DIFFERENCE_IN_MINUTES;
	}
	
	boolean isUnderAcceptedTime(Route route, double durationInMinutes) {
		if(durationInMinutes < 0) {
			throw new IllegalArgumentException("Duration can't be negative");
		}
		if(route == null) {
			throw new IllegalArgumentException("Route can't be null");
		}
		return route.getDurationInSeconds()/SECONDS_PER_MINUTE < durationInMinutes - ACCEPTABLE_DURATION_DIFFERENCE_IN_MINUTES;
	}
	
	boolean isOverAcceptedTime(Route route, double durationInMinutes) {
		if(durationInMinutes < 0) {
			throw new IllegalArgumentException("Duration can't be negative");
		}
		if(route == null) {
			throw new IllegalArgumentException("Route can't be null"); 
		}
		return route.getDurationInSeconds()/SECONDS_PER_MINUTE > durationInMinutes + ACCEPTABLE_DURATION_DIFFERENCE_IN_MINUTES;
	}

	static int getAcceptableDurationDifferenceInMinutes() {
		return ACCEPTABLE_DURATION_DIFFERENCE_IN_MINUTES;
	}

	static int getMaximumNumberOfTries() {
		return MAXIMUM_NUMBER_OF_TRIES;
	}

}
