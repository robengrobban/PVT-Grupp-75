package group75.walkInProgress.route;

import javax.persistence.Entity;
import java.util.ArrayList;
import java.util.List;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.ElementCollection;
import com.google.maps.model.DirectionsRoute;
import com.google.maps.model.LatLng;

@Entity
public class Route {
	  @Id
	  @GeneratedValue(strategy=GenerationType.AUTO)
	  private Integer id;
	  @ElementCollection
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

	public Integer getId() {
		return id;
	}

	public LatLng getStartPoint() {
		return startPoint;
	}

	public int getDuration() {
		return duration;
	}
	  
}
