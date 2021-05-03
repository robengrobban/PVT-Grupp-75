package group75.walkInProgress.route;

import java.util.ArrayList;
import java.util.List;

import com.google.maps.model.DirectionsRoute;
import com.google.maps.model.LatLng;


public class Route {
	  private List<LatLng> polyCoordinates;
	  private List<LatLng> waypoints;
	  private LatLng startPoint;
	  private int distance;
	  private int duration;
	  private LatLng northEastBound;
	  private LatLng southWestBound;

	  Route(DirectionsRoute directionsResult, List<LatLng> waypoints, LatLng startPoint) {
		  this.northEastBound = directionsResult.bounds.northeast;
		  this.southWestBound = directionsResult.bounds.southwest;
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

	public List<LatLng> getWaypoints() {
		return waypoints;
	}

	public LatLng getNorthEastBound() {
		return northEastBound;
	}

	public LatLng getSouthWestBound() {
		return southWestBound;
	}

	public double getDistance() {
		return distance;
	}

	public LatLng getStartPoint() {
		return startPoint;
	}

	public int getDuration() {
		return duration;
	}
	
	
	  
}
