package group75.walkInProgress.route;

import java.util.List;

import com.google.maps.model.LatLng;

public class GeoCalculator {
	private static final double TAO = Math.PI * 2;
	private static final int KM_PER_LATITUDE = 111;
	private static final double KM_TO_LONGITUDE_FACTOR = 111.320;
	
	

	/**
	 * Returns a LatLng at specified bearing from the startPoint
	 * and with specified distance from the startPoint.
	 * The distance is interpreted as a straight line (as the crows flies) 
	 * and does not take into account any roads or elevation differences.
	 * Angles are interpreted counterclockwise with 0 being east.
	 * The distance between the startPoint and the returned point
	 * is relatively precise (+/- 0.05 km) for small distances (up to 40 km)
	 * but gets less precise for larger distances.
	 * @throws IllegalArgumentException if startPoint is null or distanceInKm
	 * 									is less than 0
	 * @param startPoint a point from which to calculate a new point
	 * @param distanceInKm a distance as the crows flies that the new point 
	 * 						should be from the startPoint
	 * @param angleInRadians a bearing from the startPoint to the returned point.
	 * 						Negative angles and angles larger than 2*Pi are also
	 * 						accepted. 
	 * @return the LatLng at the specified distance and angle from the startPoint
	 */
	public LatLng getPointWithinDistanceFrom(LatLng startPoint, double distanceInKm, double angleInRadians) {
		if(distanceInKm < 0) {
			throw new IllegalArgumentException("Leg distance can't be negative"); 
		}
		if(startPoint == null) {
			throw new IllegalArgumentException("startPoint can't be null");
		}
		
		double distanceInKmAlongYAxis = Math.sin(angleInRadians) * distanceInKm;		
		double distanceInKmAlongXAxis = Math.cos(angleInRadians) * distanceInKm;
		
		double newLat = startPoint.lat + toLatitudeDifference(distanceInKmAlongYAxis); 
		double newLong = startPoint.lng + toLongitudeDifference(distanceInKmAlongXAxis, startPoint.lat); 

		return new LatLng(newLat, newLong);
	}
	
	private double toLatitudeDifference(double distanceInKm) {
		return distanceInKm/KM_PER_LATITUDE;
	}
	
	
	//How long one longitude is depends on what latitude you are on. 
	private double toLongitudeDifference(double distanceInKm, double atLatitude) {
		double kmPerLongitude= Math.cos(Math.toRadians(atLatitude)) * KM_TO_LONGITUDE_FACTOR;
		return distanceInKm / kmPerLongitude;
	}
	
	/**
	 * Returns the bearing in radians from the startPoint to the endPoint.
	 * Angles are calculated counterclockwise with 0 being east.
	 * @throws IllegalArgumentException if startPoint or endPoint is null
	 * @param startPoint a point from where to calculate the bearing
	 * @param endPoint a point to where to calculate the bearing
	 * @return an angle in radians between 0 and 2*Pi
	 */
	public double getBearingInRadians(LatLng startPoint, LatLng endPoint) {
		if(startPoint == null || endPoint == null) {
			throw new IllegalArgumentException("Neither of the locations can be null");
		}
		
		double lat1InRad = Math.toRadians(startPoint.lat);
		double lng1InRad = Math.toRadians(startPoint.lng);
		double lat2InRad = Math.toRadians(endPoint.lat);
		double lng2InRad = Math.toRadians(endPoint.lng);
		
		double longDiffInRad = lng2InRad - lng1InRad;
		double x = Math.sin(longDiffInRad) * Math.cos(lat2InRad);
		double y = Math.cos(lat1InRad) * Math.sin(lat2InRad) - Math.sin(lat1InRad) * Math.cos(lat2InRad) * Math.cos(longDiffInRad);
		double bearingInRad = (Math.atan2(y,x) + TAO)% TAO;
		
		return bearingInRad;
	}
	
	/**
	 * Takes a list of places and returns the place that has the bearing
	 * from the given startPoint that is closest to the specified goalBearing.
	 * Returns null if places is empty.
	 * Angles are counted counterclockwise with 0 being east.
	 * @throws IllegalArgumentException if places or startPoint is null
	 * @param places a list of places from which to choose from
	 * @param startPoint a LatLng from which to calculate the bearing
	 * @param goalBearing a bearing in radians from the startPoint, 
	 * 			to compare places against. Negative angles and angles 
	 * 			larger than 2*Pi are also accepted.
	 * @return the LatLng from places that has the closest bearing from 
	 * 			the startPoint compared to the goalBearing, null 
	 * 			if places is empty.
	 */
	public LatLng findPointWithClosestBearing(List<LatLng> places, LatLng startPoint, double goalBearing) {
		if(startPoint == null || places == null) {
			throw new IllegalArgumentException("Neither the list of places or the startPoint can be null");
		}
		//To get a radian value between 0 and 2*Pi
		goalBearing = (goalBearing % (TAO) + (TAO)) % TAO;
		double smallestDifference = Integer.MAX_VALUE;
		LatLng closestPlace = null;

		
		for (LatLng place : places) {
			double bearing = getBearingInRadians(startPoint, place);
			double bearingDifference = Math.min(TAO-Math.abs(bearing-goalBearing), Math.abs(bearing-goalBearing));
			
			if(bearingDifference < smallestDifference) {
				smallestDifference = bearingDifference;
				closestPlace = place;
			}
		}
		return closestPlace;
	}
}
