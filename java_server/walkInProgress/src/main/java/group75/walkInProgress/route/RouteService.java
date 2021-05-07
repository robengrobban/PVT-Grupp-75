package group75.walkInProgress.route;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.google.maps.*;
import com.google.maps.DirectionsApi.RouteRestriction;
import com.google.maps.errors.ApiException;
import com.google.maps.model.AddressType;
import com.google.maps.model.LatLng;
import com.google.maps.model.TravelMode;


public class RouteService {
	private static final int NUMBER_OF_WAYPOINTS = 3;
	private static final int MAXIMUM_NUMBER_OF_TRIES = 10;
	private static final int KM_PER_HOUR_WALKING = 5;
	private static final int MINUTES_PER_HOUR = 60;
	private static final double DEFAULT_ROAD_TO_CROWS_FACTOR = 0.7;
	private static final int ACCEPTABLE_DURATION_DIFFERENCE_IN_MINUTES = 5;
	private static final double DEFAULT_CROWS_FACTOR_STEP = 0.1;
	
	private int numberOfTries = 0;
	
	private double crowsStep = DEFAULT_CROWS_FACTOR_STEP;
	private boolean hasBeenIncreased = false;
	private boolean hasBeenDecreased = false;
	
	
	private final NearbyService nearbyService = new NearbyService();
	

	public Route getRoute(LatLng startPoint, double duration, double radians) {
		double crowFactor = DEFAULT_ROAD_TO_CROWS_FACTOR;
		while (numberOfTries<MAXIMUM_NUMBER_OF_TRIES) {
			numberOfTries++;
			
			double distance = ((duration/MINUTES_PER_HOUR)*KM_PER_HOUR_WALKING) * crowFactor;
			var waypoints = generateWaypoints(startPoint, distance, radians);
			Route route;
			try {
				route = generateRoute(startPoint, waypoints);
			} catch (ApiException | InterruptedException | IOException | RouteException e) {
				e.printStackTrace();
				return null;
			}

			if(Math.abs(route.getDuration()/60 - duration) <= ACCEPTABLE_DURATION_DIFFERENCE_IN_MINUTES) {
				System.out.println(numberOfTries);
				return route;
			}else {
				crowFactor = tweakCrowFactor(duration, route, crowFactor);
			}
		}
		return null;
	}

	private double tweakCrowFactor(double duration, Route route, double crowFactor) {
		if (route.getDuration()/60 < duration - ACCEPTABLE_DURATION_DIFFERENCE_IN_MINUTES){
			if(hasBeenDecreased) {
				crowsStep /=2;
				hasBeenDecreased = false;
			}
			hasBeenIncreased = true;
			crowFactor += crowsStep;
		} else {
			if(hasBeenIncreased) {
				crowsStep /=2;
				hasBeenIncreased = false;
			}
			hasBeenDecreased = true;
			crowFactor -= crowsStep;
		}
		return crowFactor;
	}


	
	public Route getRoute(LatLng startPoint, double duration, double radians, String type) {
		int legDistance = (int)((((duration/MINUTES_PER_HOUR)*KM_PER_HOUR_WALKING)*1000)/ (NUMBER_OF_WAYPOINTS + 1)*DEFAULT_ROAD_TO_CROWS_FACTOR);
		List<LatLng> places = nearbyService.getPlacesNearby(startPoint, legDistance, type);
		if(places.isEmpty()) {
			return getRoute(startPoint, duration, radians);
		}
		double closestRadians = Integer.MAX_VALUE;
		LatLng closestPlace = null;
		for (LatLng place : places) {
			double bearing = getBearing(startPoint, place);
			if(Math.abs(bearing-radians) < Math.abs(closestRadians-radians)) {
				closestRadians = bearing;
				closestPlace = place;
			}
		}

		double crowFactor = DEFAULT_ROAD_TO_CROWS_FACTOR;
		while (numberOfTries<MAXIMUM_NUMBER_OF_TRIES) {
			numberOfTries++;
			List<LatLng> wayPoints = new ArrayList<>();
			wayPoints.add(closestPlace);
			double distance = ((duration/MINUTES_PER_HOUR)*KM_PER_HOUR_WALKING) * crowFactor;
			wayPoints.addAll(generateWaypoints(startPoint, distance, closestRadians));
			Route route;
			try {
				route = generateRoute(startPoint, wayPoints);
			} catch (ApiException | InterruptedException | IOException | RouteException e) {
				e.printStackTrace();
				return null;
			}
			if(Math.abs(route.getDuration()/60 - duration) <= ACCEPTABLE_DURATION_DIFFERENCE_IN_MINUTES) {
				System.out.println("numberOfTries " + numberOfTries);
				System.out.println("duration: " + route.getDuration()/60);
				return route;
			}else {
				crowFactor = tweakCrowFactor(duration, route, crowFactor);
			}
		}
		return null;
	}
	
	private double getBearing(LatLng startPoint, LatLng place) {
		// TODO Auto-generated method stub
		return 0;
	}

	private Route generateRoute(LatLng startPoint, List<LatLng> waypoints) throws ApiException, InterruptedException, IOException, RouteException {
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
	
	private List<LatLng> generateWaypoints(LatLng startPoint, double distance, double radians) {
		
		List<LatLng> points = new ArrayList<LatLng>(); 
		for (int i = 0; i < NUMBER_OF_WAYPOINTS; i++) { 
			points.add(getPointOnCircumference( startPoint, distance / (NUMBER_OF_WAYPOINTS + 1), radians)); 
			radians += (60 * Math.PI / 180); 
		} 
		return points;
		
	}

	private LatLng getPointOnCircumference(LatLng startPoint, double legDistance, double radians) {
		double latDifference = (Math.sin(radians) * legDistance) / 111;
		double longDifference = (Math.cos(radians) * legDistance) / (Math.cos(startPoint.lat * Math.PI / 180) * 111.320); 
		double newLat = startPoint.lat + latDifference; 
		double newLong = startPoint.lng + longDifference; 
		System.out.println(newLat + "," + newLong);
		return new LatLng(newLat, newLong);
	}

}
