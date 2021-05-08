package group75.walkInProgress.route;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.google.maps.*;
import com.google.maps.DirectionsApi.RouteRestriction;
import com.google.maps.errors.ApiException;
import com.google.maps.model.LatLng;
import com.google.maps.model.TravelMode;


public class RouteService {
	
	private static final int KM_PER_LATITUDE = 111;
	private static final double KM_TO_LONGITUDE_FACTOR = 111.320;
	private static final double RADIANS_BETWEEN_LEGS = 60 * Math.PI / 180;
	private static final int NUMBER_OF_WAYPOINTS = 3;
	private static final int NUMBER_OF_LEGS = NUMBER_OF_WAYPOINTS + 1;
	private static final int MAXIMUM_NUMBER_OF_TRIES = 10;
	private static final int KM_PER_HOUR_WALKING = 5;
	private static final int MINUTES_PER_HOUR = 60;
	private static final int SECONDS_PER_MINUTE = 60;
	private static final double DEFAULT_ROAD_TO_CROWS_FACTOR = 0.7;
	private static final int ACCEPTABLE_DURATION_DIFFERENCE_IN_MINUTES = 5;
	private static final double DEFAULT_CROWS_FACTOR_STEP = 0.1;
	

	
	
	private final NearbyService nearbyService = new NearbyService();
	

	public Route getRoute(LatLng startPoint, double durationInMinutes, double radians) throws ApiException, InterruptedException, IOException, RouteException {
		return generateRoute(startPoint, durationInMinutes, radians, new ArrayList<>());
	}
	
	public Route getRoute(LatLng startPoint, double durationInMinutes, double radians, String type) throws ApiException, InterruptedException, IOException, RouteException, TypeException {
		double approxdistanceInKm = ((durationInMinutes/MINUTES_PER_HOUR)*KM_PER_HOUR_WALKING) * DEFAULT_ROAD_TO_CROWS_FACTOR;
		double legDistanceInKm = approxdistanceInKm/NUMBER_OF_LEGS;
		
		List<LatLng> places = nearbyService.getPlacesNearby(startPoint, legDistanceInKm, type);
		
		List<LatLng> pointsToPass = new ArrayList<>(); 
		
		if(!places.isEmpty()) {
			LatLng closestPlace = findPointWithClosestBearing(places, startPoint, radians);
			radians = getBearing(startPoint, closestPlace);
			pointsToPass.add(closestPlace);
		}
		
		return generateRoute(startPoint, durationInMinutes, radians, pointsToPass);
	}
	
	private LatLng findPointWithClosestBearing(List<LatLng> places, LatLng center, double goalBearing) {
		double closestBearing = Integer.MAX_VALUE;
		LatLng closestPlace = null;
		
		for (LatLng place : places) {
			double bearing = getBearing(center, place);
			
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
			System.out.println(numberOfTries);
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
	
	private boolean isWithinAcceptedTime(Route route, double durationInMinutes ) {
		return Math.abs(route.getDurationInSeconds()/SECONDS_PER_MINUTE - durationInMinutes) <= ACCEPTABLE_DURATION_DIFFERENCE_IN_MINUTES;
	}
	
	private boolean isUnderAcceptedTime(Route route, double durationInMinutes) {
		return route.getDurationInSeconds()/SECONDS_PER_MINUTE < durationInMinutes - ACCEPTABLE_DURATION_DIFFERENCE_IN_MINUTES;
	}
	
	private boolean isOverAcceptedTime(Route route, double durationInMinutes) {
		return route.getDurationInSeconds()/SECONDS_PER_MINUTE > durationInMinutes + ACCEPTABLE_DURATION_DIFFERENCE_IN_MINUTES;
	}
	
	double getBearing(LatLng startPoint, LatLng place) {
		
		double lat1InRad = Math.toRadians(startPoint.lat);
		double lng1InRad = Math.toRadians(startPoint.lng);
		double lat2InRad = Math.toRadians(place.lat);
		double lng2InRad = Math.toRadians(place.lng);
		
		double longDiffInRad = lng2InRad - lng1InRad;
		double x = Math.sin(longDiffInRad) * Math.cos(lat2InRad);
		double y = Math.cos(lat1InRad) * Math.sin(lat2InRad) - Math.sin(lat1InRad) * Math.cos(lat2InRad) * Math.cos(longDiffInRad);
		double bearingInRad = (Math.atan2(y,x) + (2*Math.PI));
		
		return bearingInRad % (Math.PI * 2);
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
	
	private List<LatLng> generateWaypoints(LatLng startPoint, double walkDistanceInKm, double radians) {
		List<LatLng> points = new ArrayList<LatLng>(); 
		
		for (int i = 0; i < NUMBER_OF_WAYPOINTS; i++) {
			double legDistance = walkDistanceInKm / NUMBER_OF_LEGS;
			points.add(getPointOnCircumference( startPoint, legDistance, radians)); 
			radians += RADIANS_BETWEEN_LEGS; 
		} 
		
		return points;
	}

	LatLng getPointOnCircumference(LatLng startPoint, double legDistanceInKM, double radians) {
		
		double distanceInKmAlongYAxis = Math.sin(radians) * legDistanceInKM;
		double latDifference = distanceInKmAlongYAxis / KM_PER_LATITUDE;
		
		//How long one longitude is depends on what latitude you are on. The factor is cosinus of the latitude times a factor in km 
		double kmPerLongitude= Math.cos(Math.toRadians(startPoint.lat)) * KM_TO_LONGITUDE_FACTOR;
		double distanceInKmAlongXAxis = Math.cos(radians) * legDistanceInKM;
		double longDifference = distanceInKmAlongXAxis / kmPerLongitude;
		
		double newLat = startPoint.lat + latDifference; 
		double newLong = startPoint.lng + longDifference; 

		return new LatLng(newLat, newLong);
	}
	
	private class CrowFactor {
		double factor;
		double step;
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
