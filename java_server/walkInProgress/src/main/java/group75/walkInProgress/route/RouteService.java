package group75.walkInProgress.route;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.google.maps.*;
import com.google.maps.errors.ApiException;
import com.google.maps.model.DirectionsRoute;
import com.google.maps.model.LatLng;
import com.google.maps.model.TravelMode;


public class RouteService {
	final static int NUMBER_OF_WAYPOINTS = 3; 
	

	public Route getRoute(LatLng startPoint, double distance) {
		var waypoints = generateWaypoints(startPoint, distance);
		
		var req = DirectionsApi.newRequest(MapsContext.getInstance());
		req.origin(startPoint);
		req.destination(startPoint);
		req.waypoints(waypoints.toArray(new LatLng[waypoints.size()]));
		req.mode(TravelMode.WALKING);
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
	
	private List<LatLng> generateWaypoints(LatLng startPoint, double distance) {
		double angle = Math.random() * Math.PI * 2; 
		List<LatLng> points = new ArrayList<LatLng>(); 
		for (int i = 0; i < NUMBER_OF_WAYPOINTS; i++) { 
			if ( i != 0) { 
				angle += (60 * Math.PI / 180); 
			} 
		points.add(getPointOnCircumference( startPoint, distance / (NUMBER_OF_WAYPOINTS + 1), angle)); 
		} 
		return points;
		
	}

	private LatLng getPointOnCircumference(LatLng startPoint, double legDistance, double angle) {
		double latDifference = (Math.sin(angle) * legDistance) / 111;
		double longDifference = (Math.cos(angle) * legDistance) / (Math.cos(startPoint.lat * Math.PI / 180) * 111.320); 
		double newLat = startPoint.lat + latDifference; 
		double newLong = startPoint.lng + longDifference; 
		return new LatLng(newLat, newLong);
	}

}
