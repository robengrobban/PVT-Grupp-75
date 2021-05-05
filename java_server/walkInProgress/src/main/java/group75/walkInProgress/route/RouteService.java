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
	private static final int ACCAPTABLE_DURATION_DIFFERENCE_IN_SECONDS = 5;
	private static final double DEFAULT_CROWS_FACTOR_STEP = 0.1;
	
	private final NearbyService nearbyService = new NearbyService();
	

	public Route getRoute(LatLng startPoint, double duration, double radians) {
		int numberOfTries = 0;
		double crowsToRoadFactor = DEFAULT_ROAD_TO_CROWS_FACTOR;
		double crowsStep = DEFAULT_CROWS_FACTOR_STEP;
		boolean hasBeenIncreased = false;
		boolean hasBeenDecreased = false;
		
		
		while (numberOfTries<MAXIMUM_NUMBER_OF_TRIES) {
			numberOfTries++;
			
			double distance = ((duration/MINUTES_PER_HOUR)*KM_PER_HOUR_WALKING) * crowsToRoadFactor;
			var waypoints = generateWaypoints(startPoint, distance, radians);
			Route route = generateRoute(startPoint, waypoints);
			if (route ==  null)
				return null;
			System.out.println("Try " + numberOfTries + " With crowfactor " + crowsToRoadFactor + " gives " + route.getDuration()/60);
			System.out.println(route.getDuration()/60 - duration);
			if(Math.abs(route.getDuration()/60 - duration) <= ACCAPTABLE_DURATION_DIFFERENCE_IN_SECONDS) {
				System.out.println(numberOfTries);
				return route;
			}else {
				if (route.getDuration()/60 < duration - ACCAPTABLE_DURATION_DIFFERENCE_IN_SECONDS){
					if(hasBeenDecreased) {
						crowsStep /=2;
						hasBeenDecreased = false;
					}
					hasBeenIncreased = true;
					crowsToRoadFactor += crowsStep;
				} else {
					if(hasBeenIncreased) {
						crowsStep /=2;
						hasBeenIncreased = false;
					}
					hasBeenDecreased = true;
					crowsToRoadFactor -= crowsStep;
				}
			}
		}
		return null;
	}
	
	public Route getRoute(LatLng startPoint, double duration, double radians, String type) {
		int distance = (int)((((duration/MINUTES_PER_HOUR)*KM_PER_HOUR_WALKING)*1000)/ (NUMBER_OF_WAYPOINTS + 1)*DEFAULT_ROAD_TO_CROWS_FACTOR);
		List<LatLng> places = nearbyService.getPlacesNearby(startPoint, distance, type);
		double closestRadians = Integer.MAX_VALUE;
		LatLng closestPlace = null;
		for (LatLng place : places) {
			double bearing = getBearing(startPoint, place);
			if(Math.abs(bearing-radians) < Math.abs(closestRadians-radians)) {
				closestRadians = bearing;
				closestPlace = place;
			}
		}
		List<LatLng> wayPoints = new ArrayList<>();
		wayPoints.add(closestPlace);
		wayPoints.addAll(generateWaypoints(startPoint, distance*(NUMBER_OF_WAYPOINTS + 1)/1000, closestRadians));
		Route route = generateRoute(startPoint, wayPoints);
		return route;
	}
	
	private double getBearing(LatLng startPoint, LatLng place) {
		// TODO Auto-generated method stub
		return 0;
	}

	private Route generateRoute(LatLng startPoint, List<LatLng> waypoints) {
		var req = DirectionsApi.newRequest(MapsContext.getInstance());
		req.origin(startPoint);
		req.destination(startPoint);
		req.waypoints(waypoints.toArray(new LatLng[waypoints.size()]));
		req.mode(TravelMode.WALKING);
		req.avoid(RouteRestriction.FERRIES);
		req.avoid(RouteRestriction.HIGHWAYS);
		req.optimizeWaypoints(false);
		try {
			var result = req.await();
			return new Route(result.routes[0], waypoints, startPoint);
		} catch (ApiException | InterruptedException | IOException e) {
			e.printStackTrace();
		} catch (RouteException e) {
		}
		return null;
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
