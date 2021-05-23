package group75.walkInProgress.route;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.google.maps.NearbySearchRequest;
import com.google.maps.PlacesApi;
import com.google.maps.errors.ApiException;
import com.google.maps.model.LatLng;
import com.google.maps.model.PlaceType;
import com.google.maps.model.PlacesSearchResponse;

public class RouteGenerator {
	private static final double DEFAULT_ROAD_TO_CROWS_FACTOR = 0.7;
	private static final double DEFAULT_CROWS_FACTOR_STEP = 0.1;
	private static final double RADIANS_BETWEEN_LEGS = Math.toRadians(60);
	private static final int NUMBER_OF_GENERATED_WAYPOINTS = 3;
	private static final int NUMBER_OF_LEGS = NUMBER_OF_GENERATED_WAYPOINTS + 1;
	private static final GeoCalculator CALCULATOR= new GeoCalculator();
	
	private static final int METERS_PER_KM = 1000;
	private static final int KM_PER_HOUR_WALKING = 5;
	private static final int MINUTES_PER_HOUR = 60;
	
	private double crowFactor = DEFAULT_ROAD_TO_CROWS_FACTOR;
	private double crowStep = DEFAULT_CROWS_FACTOR_STEP;
	private boolean hasBeenIncreased;
	private boolean hasBeenDecreased;
	
	private int numberOfTries;
	
	private LatLng startPoint;
	private double walkingDistanceInKm;
	private double bearingToFirstPointInRadians;
	
	private LatLng pointOfInterest;
	
	public RouteGenerator(LatLng startPoint, double durationInMinutes, double bearingToFirstPointInRadians) {
		if(startPoint == null) {
			throw new IllegalArgumentException("StartPoint can't be null");
		}
		if (durationInMinutes<0) {
			throw new IllegalArgumentException("Duration can't be negative");
		}
		this.startPoint = startPoint;
		this.walkingDistanceInKm = (durationInMinutes/MINUTES_PER_HOUR)*KM_PER_HOUR_WALKING;
		this.bearingToFirstPointInRadians = bearingToFirstPointInRadians;
	}
	
	public void setTypeOfInterest(String type) throws ApiException, InterruptedException, IOException, TypeException {
		PlaceType placeType;
		if(type == null) {
			throw new IllegalArgumentException("Type can not be null");
		}
		try {
			placeType = PlaceType.valueOf(type.toUpperCase());
		} catch (IllegalArgumentException e) {
			throw new TypeException(type + " is not a valid type");
		}
		
		double approxCrowDistanceInKm = walkingDistanceInKm * DEFAULT_ROAD_TO_CROWS_FACTOR;
		double legDistanceInKm = approxCrowDistanceInKm/NUMBER_OF_LEGS;
		
		List<LatLng> places = getPlacesNearby(legDistanceInKm, placeType);
		
		if(!places.isEmpty()) {
			LatLng closestPlace = CALCULATOR.findPointWithClosestBearing(places, startPoint, bearingToFirstPointInRadians);
			bearingToFirstPointInRadians = CALCULATOR.getBearingInRadians(startPoint, closestPlace);
			pointOfInterest = closestPlace;
		}
	}
	
	List<LatLng> getPlacesNearby(double distanceInKm, PlaceType type) throws ApiException, InterruptedException, IOException {
		List<LatLng> places = new ArrayList<>();
		NearbySearchRequest request = getNearbySearchRequest();
		request.type(type)
				.radius((int)(distanceInKm*METERS_PER_KM));
		PlacesSearchResponse result = sendNearbySearchRequest(request); 

		for(var res : result.results) {
			places.add(res.geometry.location);
		}

		return places;
	}
	
	NearbySearchRequest getNearbySearchRequest() {
		return PlacesApi.nearbySearchQuery(MapsContext.getInstance(), startPoint);
	}
	
	PlacesSearchResponse sendNearbySearchRequest(NearbySearchRequest request) throws ApiException, InterruptedException, IOException {
		return request.await();
	}
	

	public Route tryToFindRoute() throws ApiException, InterruptedException, IOException, RouteException {
		numberOfTries++;
		List<LatLng> waypoints = new ArrayList<>();
		if(pointOfInterest != null) {
			waypoints.add(pointOfInterest);
		}
		double distance = walkingDistanceInKm * crowFactor;
		waypoints.addAll(generateWaypoints(distance));
		
		return getRouteGetter().getRoute(startPoint, waypoints);
	}
	
	RouteGetter getRouteGetter() throws ApiException, InterruptedException, IOException, RouteException {
		return new RouteGetter();
	}
	
	public void increaseCrowFactor() {
		if(hasBeenDecreased) {
			crowStep /=2;
		}
		hasBeenIncreased = true;
		crowFactor += crowStep;
	}
	
	public void decreaseCrowFactor() {
		if(hasBeenIncreased) {
			crowStep /=2;
		}
		hasBeenDecreased = true;
		crowFactor -= crowStep;
	}
	
	List<LatLng> generateWaypoints(double walkDistanceInKm) {
		if(walkDistanceInKm < 0) {
			throw new IllegalArgumentException("Walk distance can't be negative");
		}
		List<LatLng> points = new ArrayList<LatLng>(); 
		double bearing = bearingToFirstPointInRadians;
		for (int i = 0; i < NUMBER_OF_GENERATED_WAYPOINTS; i++) {
			double legDistance = walkDistanceInKm / NUMBER_OF_LEGS;
			points.add(CALCULATOR.getPointWithinDistanceFrom( startPoint, legDistance, bearing)); 
			bearing += RADIANS_BETWEEN_LEGS; 
		} 
		
		return points;
	}
	
	public int getNumberOfTries() {
		return numberOfTries;
	}

	double getCrowFactor() {
		return crowFactor;
	}

	double getCrowStep() {
		return crowStep;
	}

	double getBearingToFirstPointInRadians() {
		return bearingToFirstPointInRadians;
	}
	
	static int getNumberOfWaypointsToGenerate() {
		return NUMBER_OF_GENERATED_WAYPOINTS;
	}

	static double getRadiansBetweenLegs() {
		return RADIANS_BETWEEN_LEGS;
	}

	LatLng getPointOfInterest() {
		return pointOfInterest;
	}

	static double getDefaultRoadToCrowsFactor() {
		return DEFAULT_ROAD_TO_CROWS_FACTOR;
	}

	static int getNumberOfLegs() {
		return NUMBER_OF_LEGS;
	}

	double getWalkingDistanceInKm() {
		return walkingDistanceInKm;
	}


}
