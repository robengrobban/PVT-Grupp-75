package group75.walkInProgress.route;

import static org.junit.jupiter.api.Assertions.*;

import java.util.List;

import org.junit.jupiter.api.Test;

import com.google.maps.model.LatLng;

class RouteServiceTest { 
	
	private static final double DEFAULT_LATITUDE = 58.21;
	private static final double DEFAULT_LONGITUDE = 17.34;
	private static final LatLng DEFAULT_LATLNG = new LatLng(DEFAULT_LATITUDE, DEFAULT_LONGITUDE);

	private static final double DEFAULT_ANGLE_IN_RADIANS = Math.toRadians(170);
	private static final int DEFAULT_DURATION_IN_MINUTES = 40;
	private static final double DEFAULT_WALK_DISTANCE = 5.5;

	private static final int DEFAULT_NEGATIVE_NUMBER = -5;
	
	private static final int SECONDS_PER_MINUTE = 60;
	
	private static final double ERROR_MARGIN_FOR_DOUBLES = 0.05;
	
	private static final RouteService service = new RouteService();
	
	
	//IsWithinAcceptedTime
	
	@Test
	void isWithinAcceptedTimeReturnsTrueIfRouteDurationIsExactlySpecifiedDuration() {
		Route route = new Route();
		route.setDurationInSeconds(DEFAULT_DURATION_IN_MINUTES*SECONDS_PER_MINUTE);
		assertTrue(service.isWithinAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
	}
	
	@Test
	void isWithinAcceptedTimeReturnsTrueIfRouteDurationIsLessThanSpecifiedButWithinAcceptedMargin() {
		Route route = new Route();
		int routeDurationToTest = DEFAULT_DURATION_IN_MINUTES-RouteService.getAcceptableDurationDifferenceInMinutes()/2;
		route.setDurationInSeconds(routeDurationToTest*SECONDS_PER_MINUTE);
		assertTrue(service.isWithinAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
	}
	
	@Test
	void isWithinAcceptedTimeReturnsTrueIfRouteDurationIsLargerThanSpecifiedButWithinAcceptedMargin() {
		Route route = new Route();
		int routeDurationToTest = DEFAULT_DURATION_IN_MINUTES+RouteService.getAcceptableDurationDifferenceInMinutes()/2;
		route.setDurationInSeconds(routeDurationToTest*SECONDS_PER_MINUTE);
		assertTrue(service.isWithinAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
	}
	@Test
	void isWithinAcceptedTimeReturnsTrueIfRouteDurationIsExactlyMinimalAcceptedDuration() {
		Route route = new Route();
		int routeDurationToTest = DEFAULT_DURATION_IN_MINUTES-RouteService.getAcceptableDurationDifferenceInMinutes();
		route.setDurationInSeconds(routeDurationToTest*SECONDS_PER_MINUTE);
		assertTrue(service.isWithinAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
	}
	
	@Test
	void isWithinAcceptedTimeReturnsTrueIfRouteDurationIsExactlyMaximalAcceptedDuration() {
		Route route = new Route();
		int routeDurationToTest = DEFAULT_DURATION_IN_MINUTES+RouteService.getAcceptableDurationDifferenceInMinutes();
		route.setDurationInSeconds(routeDurationToTest*SECONDS_PER_MINUTE);
		assertTrue(service.isWithinAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
	}
	
	@Test
	void isWithinAcceptedTimeReturnsFalseIfRouteDurationIsLargerThanAcceptedRange() {
		Route route = new Route();
		int routeDurationToTest = DEFAULT_DURATION_IN_MINUTES+RouteService.getAcceptableDurationDifferenceInMinutes()+1;
		route.setDurationInSeconds(routeDurationToTest*SECONDS_PER_MINUTE);
		assertFalse(service.isWithinAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
	}
	
	@Test
	void isWithinAcceptedTimeReturnsFalseIfRouteDurationIsSmallerThanAcceptedRange() {
		Route route = new Route();
		int routeDurationToTest = DEFAULT_DURATION_IN_MINUTES-RouteService.getAcceptableDurationDifferenceInMinutes()-1;
		route.setDurationInSeconds(routeDurationToTest*SECONDS_PER_MINUTE);
		assertFalse(service.isWithinAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
	}
	
	@Test
	void isWithinAcceptedTimeThrowsIAEIfDurationIsLessThanZero() {
		assertThrows(IllegalArgumentException.class, ()->{service.isWithinAcceptedTime(new Route(), DEFAULT_NEGATIVE_NUMBER);});
	}
	
	@Test
	void isWithinAcceptedTimeThrowsIAEIfRouteIsNull() {
		assertThrows(IllegalArgumentException.class, ()->{service.isWithinAcceptedTime(null, DEFAULT_DURATION_IN_MINUTES);});
	}
	
	//IsUnderAcceptedTime
	
		@Test
		void isUnderAcceptedTimeReturnsFalseIfRouteDurationIsExactlySpecifiedDuration() {
			Route route = new Route();
			route.setDurationInSeconds(DEFAULT_DURATION_IN_MINUTES*SECONDS_PER_MINUTE);
			assertFalse(service.isUnderAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
		}
		
		@Test
		void isWithinAcceptedTimeReturnsFalseIfRouteDurationIsLessThanSpecifiedButWithinAcceptedMargin() {
			Route route = new Route();
			int routeDurationToTest = DEFAULT_DURATION_IN_MINUTES-RouteService.getAcceptableDurationDifferenceInMinutes()/2;
			route.setDurationInSeconds(routeDurationToTest*SECONDS_PER_MINUTE);
			assertFalse(service.isUnderAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
		}

		@Test
		void isUnderAcceptedTimeReturnsFalseIfRouteDurationIsExactlyMinimalAcceptedDuration() {
			Route route = new Route();
			int routeDurationToTest = DEFAULT_DURATION_IN_MINUTES-RouteService.getAcceptableDurationDifferenceInMinutes();
			route.setDurationInSeconds(routeDurationToTest*SECONDS_PER_MINUTE);
			assertFalse(service.isUnderAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
		}
		
		@Test
		void isUnderAcceptedTimeReturnsFalseIfRouteDurationIsLargerThanAcceptedRange() {
			Route route = new Route();
			int routeDurationToTest = DEFAULT_DURATION_IN_MINUTES+RouteService.getAcceptableDurationDifferenceInMinutes()+1;
			route.setDurationInSeconds(routeDurationToTest*SECONDS_PER_MINUTE);
			assertFalse(service.isUnderAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
		}
		
		@Test
		void isUnderAcceptedTimeReturnsTrueIfRouteDurationIsSmallerThanAcceptedRange() {
			Route route = new Route();
			int routeDurationToTest = DEFAULT_DURATION_IN_MINUTES-RouteService.getAcceptableDurationDifferenceInMinutes()-1;
			route.setDurationInSeconds(routeDurationToTest*SECONDS_PER_MINUTE);
			assertTrue(service.isUnderAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
		}
		
		@Test
		void isUnderAcceptedTimeThrowsIAEIfDurationIsLessThanZero() {
			assertThrows(IllegalArgumentException.class, ()->{service.isUnderAcceptedTime(new Route(), DEFAULT_NEGATIVE_NUMBER);});
		}
		
		@Test
		void isUnderAcceptedTimeThrowsIAEIfRouteIsNull() {
			assertThrows(IllegalArgumentException.class, ()->{service.isUnderAcceptedTime(null, DEFAULT_DURATION_IN_MINUTES);});
		}
		
		//IsOverAcceptedTime
		
		@Test
		void isOverAcceptedTimeReturnsFalseIfRouteDurationIsExactlySpecifiedDuration() {
			Route route = new Route();
			route.setDurationInSeconds(DEFAULT_DURATION_IN_MINUTES*SECONDS_PER_MINUTE);
			assertFalse(service.isOverAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
		}
		
		@Test
		void isOverAcceptedTimeReturnsFalseIfRouteDurationIsLargerThanSpecifiedButWithinAcceptedMargin() {
			Route route = new Route();
			int routeDurationToTest = DEFAULT_DURATION_IN_MINUTES+RouteService.getAcceptableDurationDifferenceInMinutes()/2;
			route.setDurationInSeconds(routeDurationToTest*SECONDS_PER_MINUTE);
			assertFalse(service.isOverAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
		}

		@Test
		void isOverAcceptedTimeReturnsFalseIfRouteDurationIsExactlyMaximalAcceptedDuration() {
			Route route = new Route();
			int routeDurationToTest = DEFAULT_DURATION_IN_MINUTES+RouteService.getAcceptableDurationDifferenceInMinutes();
			route.setDurationInSeconds(routeDurationToTest*SECONDS_PER_MINUTE);
			assertFalse(service.isOverAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
		}
		
		@Test
		void isOverAcceptedTimeReturnsFalseIfRouteDurationIsSmallerThanAcceptedRange() {
			Route route = new Route();
			int routeDurationToTest = DEFAULT_DURATION_IN_MINUTES-RouteService.getAcceptableDurationDifferenceInMinutes()-1;
			route.setDurationInSeconds(routeDurationToTest*SECONDS_PER_MINUTE);
			assertFalse(service.isOverAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
		}
		
		@Test
		void isOverAcceptedTimeReturnsTrueIfRouteDurationIsLargerThanAcceptedRange() {
			Route route = new Route();
			int routeDurationToTest = DEFAULT_DURATION_IN_MINUTES+RouteService.getAcceptableDurationDifferenceInMinutes()+1;
			route.setDurationInSeconds(routeDurationToTest*SECONDS_PER_MINUTE);
			assertTrue(service.isOverAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
		}
		
		@Test
		void isOverAcceptedTimeThrowsIAEIfDurationIsLessThanZero() {
			assertThrows(IllegalArgumentException.class, ()->{service.isOverAcceptedTime(new Route(), DEFAULT_NEGATIVE_NUMBER);});
		}
		
		@Test
		void isOverAcceptedTimeThrowsIAEIfRouteIsNull() {
			assertThrows(IllegalArgumentException.class, ()->{service.isOverAcceptedTime(null, DEFAULT_DURATION_IN_MINUTES);});
		}
	

	
	
	//Calculation from https://stackoverflow.com/questions/3694380/calculating-distance-between-two-points-using-latitude-longitude
	private double calculateDistanceBetweenInKm(LatLng point1, LatLng point2) {
		double lat1 = point1.lat;
		double lon1 = point1.lng;
		double lon2 = point2.lng;
		double lat2 = point2.lat;
	    final int R = 6371; // Radius of the earth

	    double latDistance = Math.toRadians(lat2 - lat1);
	    double lonDistance = Math.toRadians(lon2 - lon1);
	    double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
	            + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
	            * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
	    double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
	    double distance = R * c;

	    return distance;
	}
	
	private double calculateAngleBetweenInRadians(LatLng point1, LatLng point2) {
		double lat1InRad = Math.toRadians(point1.lat);
		double lng1InRad = Math.toRadians(point1.lng);
		double lat2InRad = Math.toRadians(point2.lat);
		double lng2InRad = Math.toRadians(point2.lng);
		
		double longDiffInRad = lng2InRad - lng1InRad;
		double x = Math.sin(longDiffInRad) * Math.cos(lat2InRad);
		double y = Math.cos(lat1InRad) * Math.sin(lat2InRad) - Math.sin(lat1InRad) * Math.cos(lat2InRad) * Math.cos(longDiffInRad);
		double bearingInRad = (Math.atan2(y,x) + (2*Math.PI))% (Math.PI * 2);
		
		return bearingInRad;
	}
	//generateWayPoints
	@Test
	void generateWayPointsGeneratesRightNumberOfWayPoints() {
		List<LatLng> waypoints = service.generateWaypoints(DEFAULT_LATLNG, DEFAULT_WALK_DISTANCE, DEFAULT_ANGLE_IN_RADIANS);
		assertEquals(RouteService.getNumberOfWaypoints(), waypoints.size());
	}
	
	@Test
	void generateWayPointsGeneratesWaypointsWithTheRightWalkDistance() {
		List<LatLng> waypoints = service.generateWaypoints(DEFAULT_LATLNG, DEFAULT_WALK_DISTANCE, DEFAULT_ANGLE_IN_RADIANS);
		double walkDistance = calculateDistanceBetweenInKm(DEFAULT_LATLNG, waypoints.get(0));
		for (int i = 0; i<waypoints.size()-1; i++) {
			walkDistance += calculateDistanceBetweenInKm(waypoints.get(i), waypoints.get(i+1)); 
		}
		walkDistance += calculateDistanceBetweenInKm(waypoints.get(waypoints.size()-1), DEFAULT_LATLNG);
		assertEquals(DEFAULT_WALK_DISTANCE, walkDistance, ERROR_MARGIN_FOR_DOUBLES);
	}
	
	@Test
	void generateWayPointsGeneratesWaypointsWithTheRightAngleBetweenThem() {
		List<LatLng> waypoints = service.generateWaypoints(DEFAULT_LATLNG, DEFAULT_WALK_DISTANCE, DEFAULT_ANGLE_IN_RADIANS);
		for (int i = 0; i<waypoints.size()-1; i++) {
			double angleToCurrent = calculateAngleBetweenInRadians(DEFAULT_LATLNG, waypoints.get(i));
			double angleToNext = calculateAngleBetweenInRadians(DEFAULT_LATLNG, waypoints.get(i+1));
			double angleDifference = (angleToNext-angleToCurrent+2*Math.PI) % (2*Math.PI);
			assertEquals(RouteService.getRadiansBetweenLegs(), angleDifference, ERROR_MARGIN_FOR_DOUBLES);
		}
	} 
	
	@Test
	void generateWayPointsGeneratesFirstWaypointWithGivenAngle() {
		List<LatLng> waypoints = service.generateWaypoints(DEFAULT_LATLNG, DEFAULT_WALK_DISTANCE, DEFAULT_ANGLE_IN_RADIANS);
		assertEquals(DEFAULT_ANGLE_IN_RADIANS, calculateAngleBetweenInRadians(DEFAULT_LATLNG, waypoints.get(0)), ERROR_MARGIN_FOR_DOUBLES);
	}
	
	@Test
	void generateWayPointsGeneratesOnlyCopiesOfStartpointIfWalkDistanceIsZero() {
		List<LatLng> waypoints = service.generateWaypoints(DEFAULT_LATLNG, 0, DEFAULT_ANGLE_IN_RADIANS);
		for(LatLng point : waypoints) {
			assertEquals(DEFAULT_LATLNG, point);
		}
	}
	
	@Test
	void generateWayPointsThrowsIAEOnNegativeWalkDistance() {
		LatLng startPoint = DEFAULT_LATLNG;
		assertThrows(IllegalArgumentException.class, ()->{
			service.generateWaypoints(startPoint, DEFAULT_NEGATIVE_NUMBER, DEFAULT_ANGLE_IN_RADIANS);
		});
	}
	
	@Test
	void generateWayPointsThrowsIAEIfStartPointIsNull() {
		LatLng startPoint = null;
		assertThrows(IllegalArgumentException.class, ()->{
			service.generateWaypoints(startPoint, DEFAULT_WALK_DISTANCE, DEFAULT_ANGLE_IN_RADIANS);
		});
	}

}
