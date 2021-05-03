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
	private static final int NUMBER_OF_WAYPOINTS = 3;
	private static final int MAXIMUM_NUMBER_OF_TRIES = 10;
	private static final int KM_PER_HOUR_WALKING = 5;
	private static final int MINUTES_PER_HOUR = 60;
	private static final double DEFAULT_CROWS_TO_ROAD_FACTOR = 1.4;
	private static final int ACCAPTABLE_DURATION_DIFFERENCE_IN_SECONDS = 5;
	

	public Route getRoute(LatLng startPoint, double duration, double radians) {
		int numberOfTries = 0;
		double crowsToRoadFactor = DEFAULT_CROWS_TO_ROAD_FACTOR;
		
		while (numberOfTries<MAXIMUM_NUMBER_OF_TRIES) {
			numberOfTries++;
			
			double distance = ((duration/MINUTES_PER_HOUR)*KM_PER_HOUR_WALKING) / crowsToRoadFactor;
			var waypoints = generateWaypoints(startPoint, distance, radians);
			Route route = generateRoute(startPoint, waypoints);
			System.out.println("Try " + numberOfTries + " With crowfactor " + crowsToRoadFactor + " gives " + route.getDuration()/60);
			System.out.println(route.getDuration()/60 - duration);
			if(Math.abs(route.getDuration()/60 - duration) <= ACCAPTABLE_DURATION_DIFFERENCE_IN_SECONDS) {
				System.out.println(numberOfTries);
				return route;
			}else {
				if (route.getDuration()/60 < duration - ACCAPTABLE_DURATION_DIFFERENCE_IN_SECONDS){
					crowsToRoadFactor -= 0.2;
				} else {
					crowsToRoadFactor += 0.2;
				}
			}
		}
		return null;
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
			// TODO Auto-generated catch block
			e.printStackTrace();
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
		return new LatLng(newLat, newLong);
	}

}
