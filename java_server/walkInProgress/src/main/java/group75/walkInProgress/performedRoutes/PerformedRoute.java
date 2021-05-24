package group75.walkInProgress.performedRoutes;

import java.time.LocalDateTime;
import java.util.List;

import javax.persistence.ElementCollection;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;

import com.google.maps.model.LatLng;



@Entity
public class PerformedRoute {
	
	@Id
	@GeneratedValue(strategy = GenerationType.AUTO)
	private Integer id;
	
	private int userId;
	private LatLng startPoint;
	@ElementCollection
	private List<LatLng> waypoints;
	private int distance;
	private int actualDuration;


	private LocalDateTime timeFinished;
	
	public PerformedRoute(){}

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

	public int getActualDuration() {
		return actualDuration;
	}

	public void setActualDuration(int actualDuration) {
		this.actualDuration = actualDuration;
	}

	public LocalDateTime getTimeFinished() {
		return timeFinished;
	}

	public void setTimeFinished(LocalDateTime timeFinished) {
		this.timeFinished = timeFinished;
	}
	
	public int getUserId() {
		return userId;
	}

	public void setUserId(int userId) {
		this.userId = userId;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((timeFinished == null) ? 0 : timeFinished.hashCode());
		result = prime * result + userId;
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
		PerformedRoute other = (PerformedRoute) obj;
		if (timeFinished == null) {
			if (other.timeFinished != null)
				return false;
		} else if (!timeFinished.equals(other.timeFinished))
			return false;
		if (userId != other.userId)
			return false;
		return true;
	}
	@Override
	public String toString() {
		return "PerformedRoute [timeFinished=" + timeFinished + "]";
	}
	

}
