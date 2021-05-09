package group75.walkInProgress.route;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Service;

import com.google.maps.*;
import com.google.maps.DirectionsApi.RouteRestriction;
import com.google.maps.errors.ApiException;
import com.google.maps.model.LatLng;
import com.google.maps.model.TravelMode;

@Service
public class RouteService implements IRouteService {
	
	private static final double RADIANS_BETWEEN_LEGS = 60 * Math.PI / 180;
	private static final int NUMBER_OF_WAYPOINTS = 3;
	private static final int NUMBER_OF_LEGS = NUMBER_OF_WAYPOINTS + 1;
	private static final int MAXIMUM_NUMBER_OF_TRIES = 10;
	private static final int KM_PER_HOUR_WALKING = 5;
	private static final int MINUTES_PER_HOUR = 60;
	private static final int SECONDS_PER_MINUTE = 60;
	private static final double DEFAULT_ROAD_TO_CROWS_FACTOR = 0.7;
	private static final int ACCEPTABLE_DURATION_DIFFERENCE_IN_MINUTES = 10;
	private static final double DEFAULT_CROWS_FACTOR_STEP = 0.1;
	

	
	private final NearbyService nearbyService;
	
	private final GeoCalculator geoCalculator;
	
	
	public RouteService() {
		this(new NearbyService());
	}
	
	
	RouteService(NearbyService nearbyService) {
		this.nearbyService = nearbyService;	
		this.geoCalculator = new GeoCalculator();
	}
	

	@Override
	public Route getRoute(LatLng startPoint, double durationInMinutes, double radians) throws ApiException, InterruptedException, IOException, RouteException {
		return generateRoute(startPoint, durationInMinutes, radians, new ArrayList<>());
	}
	
	@Override
	public Route getRoute(LatLng startPoint, double durationInMinutes, double radians, String type) throws ApiException, InterruptedException, IOException, RouteException, TypeException {
		double approxdistanceInKm = ((durationInMinutes/MINUTES_PER_HOUR)*KM_PER_HOUR_WALKING) * DEFAULT_ROAD_TO_CROWS_FACTOR;
		double legDistanceInKm = approxdistanceInKm/NUMBER_OF_LEGS;
		
		List<LatLng> places = nearbyService.getPlacesNearby(startPoint, legDistanceInKm, type);
		
		List<LatLng> pointsToPass = new ArrayList<>();  
		
		if(!places.isEmpty()) {
			LatLng closestPlace = findPointWithClosestBearing(places, startPoint, radians);
			radians = geoCalculator.getBearingInRadians(startPoint, closestPlace);
			pointsToPass.add(closestPlace);
		}
		
		return generateRoute(startPoint, durationInMinutes, radians, pointsToPass);
	}
	
	private LatLng findPointWithClosestBearing(List<LatLng> places, LatLng center, double goalBearing) {
		double closestBearing = Integer.MAX_VALUE;
		LatLng closestPlace = null;
		
		for (LatLng place : places) {
			double bearing = geoCalculator.getBearingInRadians(center, place);
			
			if(Math.abs(bearing-goalBearing) < Math.abs(closestBearing-goalBearing)) {
				closestBearing = bearing;
				closestPlace = place;
			}
		}
		return closestPlace;
	}
	
	private Route generateRoute(LatLng startPoint, double durationInMinutes, double radians, List<LatLng> pointsToPass) throws ApiException, InterruptedException, IOException, RouteException {
		int numberOfTries = 0;
		CrowFactor crowFactor = new CrowFactor(DEFAULT_ROAD_TO_CROWS_FACTOR, DEFAULT_CROWS_FACTOR_STEP);
		double crowDistance = (durationInMinutes/MINUTES_PER_HOUR)*KM_PER_HOUR_WALKING;
		
		while (numberOfTries<MAXIMUM_NUMBER_OF_TRIES) {
			numberOfTries++;
			List<LatLng> wayPoints = new ArrayList<>(pointsToPass);

			double distance = crowDistance * crowFactor.factor;
			wayPoints.addAll(generateWaypoints(startPoint, distance, radians));
			Route route = getRouteFromGoogle(startPoint, wayPoints);
			
			System.out.println("Try number " + numberOfTries + " gave duration " + route.getDurationInSeconds()/60 + " with crowfactor " + crowFactor.factor);
			
			if(isWithinAcceptedTime(route, durationInMinutes)) {
				return route;
			}else if (isUnderAcceptedTime(route, durationInMinutes)){
				crowFactor.increase();
			} else {
				crowFactor.decrease();
			}
		}
		return null;
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

	private Route getRouteFromGoogle(LatLng startPoint, List<LatLng> waypoints) throws ApiException, InterruptedException, IOException, RouteException {
		var req = DirectionsApi.newRequest(MapsContext.getInstance());
		
		req.origin(startPoint);
		req.destination(startPoint);
		req.waypoints(waypoints.toArray(new LatLng[waypoints.size()]));
		req.mode(TravelMode.WALKING);
		req.avoid(RouteRestriction.FERRIES);
		req.avoid(RouteRestriction.HIGHWAYS);
		req.optimizeWaypoints(false);
		
		var result = req.await();
		
		return new Route(result.routes[0], waypoints, startPoint);
	}
	
	List<LatLng> generateWaypoints(LatLng startPoint, double walkDistanceInKm, double radians) {
		if(walkDistanceInKm < 0) {
			throw new IllegalArgumentException("Walk distance can't be negative");
		}
		if(startPoint == null) {
			throw new IllegalArgumentException("startPoint can't be null");
		}
		List<LatLng> points = new ArrayList<LatLng>(); 
		
		for (int i = 0; i < NUMBER_OF_WAYPOINTS; i++) {
			double legDistance = walkDistanceInKm / NUMBER_OF_LEGS;
			points.add(geoCalculator.getPointWithinDistanceFrom( startPoint, legDistance, radians)); 
			radians += RADIANS_BETWEEN_LEGS; 
		} 
		
		return points;
	}
	
	static int getAcceptableDurationDifferenceInMinutes() {
		return ACCEPTABLE_DURATION_DIFFERENCE_IN_MINUTES;
	}

	static int getNumberOfWaypoints() {
		return NUMBER_OF_WAYPOINTS;
	}

	static double getRadiansBetweenLegs() {
		return RADIANS_BETWEEN_LEGS;
	}

	private static class CrowFactor {
		private double factor;
		private double step;
		private boolean hasBeenIncreased;
		private boolean hasBeenDecreased;
		
		CrowFactor(double startFactor, double startStep) {
			factor = startFactor;
			step = startStep;
		}
		
		void increase() {
			if(hasBeenDecreased) {
				step /=2;
				hasBeenDecreased = false;
			}
			hasBeenIncreased = true;
			factor += step;
		}
		
		void decrease() {
			if(hasBeenIncreased) {
				step /=2;
				hasBeenIncreased = false;
			}
			hasBeenDecreased = true;
			factor -= step;
		}
	}

}
