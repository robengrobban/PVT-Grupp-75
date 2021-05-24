package group75.walkInProgress.bookmarks;

import java.util.List;

import javax.persistence.ElementCollection;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;

import com.google.maps.model.LatLng;

@Entity
public class RouteInfo {

	@Id
	@GeneratedValue(strategy = GenerationType.AUTO)
	private Integer id;

	
	private LatLng startPoint;
	@ElementCollection
	private List<LatLng> waypoints;
	private int distance;
	private int durationInSeconds;

	public RouteInfo(LatLng startPoint, List<LatLng> waypoints, int distance, int durationInSeconds) {
		this.startPoint = startPoint;
		this.waypoints = waypoints;
		this.distance = distance;
		this.durationInSeconds = durationInSeconds;
	}
	
	public RouteInfo() {}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

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

	public int getDistance() {
		return distance;
	}

	public void setDistance(int distance) {
		this.distance = distance;
	}

	public int getDurationInSeconds() {
		return durationInSeconds;
	}

	public void setDurationInSeconds(int durationInSeconds) {
		this.durationInSeconds = durationInSeconds;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((startPoint == null) ? 0 : startPoint.hashCode());
		result = prime * result + ((waypoints == null) ? 0 : waypoints.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		RouteInfo other = (RouteInfo) obj;
		if (startPoint == null) {
			if (other.startPoint != null)
				
				return false;
		} else if (!startPoint.equals(other.startPoint))
			return false;
		if (waypoints == null) {
			if (other.waypoints != null)
				return false;
		} else if (waypoints.size()!=other.waypoints.size()){
			return false;
		} else {
			for(int i = 0; i<waypoints.size(); i++) {
				if(!waypoints.get(i).equals(other.waypoints.get(i)))
					return false;
			}
		}
		return true;
	}

	@Override
	public String toString() {
		return "RouteInfo [id=" + id + ", startPoint=" + startPoint + ", waypoints=" + waypoints + ", distance="
				+ distance + ", durationInSeconds=" + durationInSeconds + "]";
	}
	
	

}
