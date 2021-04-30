package group75.walkInProgress.route;

import java.util.ArrayList;
import java.util.List;

import com.google.maps.model.DirectionsResult;
import com.google.maps.model.DirectionsRoute;
import com.google.maps.model.LatLng;


public class Route {
	  List<LatLng> polyCoordinates;
	  List<LatLng> waypoints;
	  LatLng startPoint;
	  int distance;
	  int duration;

	  Route(DirectionsRoute directionsResult, List<LatLng> waypoints, LatLng startPoint) {
		  this.waypoints = waypoints;
		  this.startPoint = startPoint;
		  polyCoordinates = new ArrayList<LatLng>();
		  for (var leg : directionsResult.legs) {
			  for (var step : leg.steps) {
				  polyCoordinates.addAll(step.polyline.decodePath());
				  distance += step.distance.inMeters;
				  duration += step.duration.inSeconds;
			  }
			  
		  }
		  
	  }

	public List<LatLng> getPolyCoordinates() {
		return polyCoordinates;
	}

	public List<LatLng> getwaypoints() {
		return waypoints;
	}

	public double getDistance() {
		return distance;
	}

	public List<LatLng> getWaypoints() {
		return waypoints;
	}

	public LatLng getStartPoint() {
		return startPoint;
	}

	public int getDuration() {
		return duration;
	}
	
	
	  
}
