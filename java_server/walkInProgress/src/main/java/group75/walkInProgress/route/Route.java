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
	  private int durationInSeconds;
	  private LatLng northEastBound;
	  private LatLng southWestBound;


	Route(DirectionsRoute directionsResult, List<LatLng> waypoints, LatLng startPoint) throws RouteException {
		  this.northEastBound = directionsResult.bounds.northeast;
		  this.southWestBound = directionsResult.bounds.southwest;
		  this.waypoints = waypoints;
		  this.startPoint = startPoint;
		  polyCoordinates = new ArrayList<LatLng>();
		  for (var leg : directionsResult.legs) {
			  for (var step : leg.steps) {
				  if(step.htmlInstructions.toLowerCase().contains("ferry"))
					  throw new RouteException("A walking route can't include a ferry");
				  polyCoordinates.addAll(step.polyline.decodePath());
				  distance += step.distance.inMeters;
				  durationInSeconds += step.duration.inSeconds;
			  }
		  }
	  }
	  

	public Route() {}



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

	public int getDurationInSeconds() {
		return durationInSeconds;
	}


	public void setPolyCoordinates(List<LatLng> polyCoordinates) {
		this.polyCoordinates = polyCoordinates;
	}


	public void setWaypoints(List<LatLng> waypoints) {
		this.waypoints = waypoints;
	}


	public void setStartPoint(LatLng startPoint) {
		this.startPoint = startPoint;
	}


	public void setDistance(int distance) {
		this.distance = distance;
	}


	public void setDurationInSeconds(int duration) {
		this.durationInSeconds = duration;
	}


	public void setNorthEastBound(LatLng northEastBound) {
		this.northEastBound = northEastBound;
	}


	public void setSouthWestBound(LatLng southWestBound) {
		this.southWestBound = southWestBound;
	}
	
	
	  
}
