package group75.walkInProgress.route;

import java.util.List;

import com.google.maps.model.LatLng;

public class BasicRouteInfo {
	LatLng startPoint;
	public LatLng getStartPoint() {
		return startPoint;
	}
	public void setStartPoint(LatLng startPoint) {
		this.startPoint = startPoint;
	}
	public List<LatLng> getWaypoints() {
		return waypoints;
	}
	public void setWaypoints(List<LatLng> waypoints) {
		this.waypoints = waypoints;
	}
	List<LatLng> waypoints;

}
