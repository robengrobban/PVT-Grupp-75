package group75.walkInProgress.route;

import static org.junit.jupiter.api.Assertions.*;

import java.util.ArrayList;

import org.junit.jupiter.api.Test;

import com.google.maps.model.LatLng;

class GeoCalculatorTest {
	private static final double TAO = 2*Math.PI;
	private static final double DEFAULT_LATITUDE = 58.21;
	private static final double DEFAULT_LONGITUDE = 17.34;
	
	private static final LatLng DEFAULT_LATLNG = new LatLng(DEFAULT_LATITUDE, DEFAULT_LONGITUDE);
	
	private static final double DEFAULT_DISTANCE_IN_KM = 2.5;
	private static final double DEFAULT_LARGE_DISTANCE = 40;
	private static final double DEFAULT_SMALL_DISTANCE = 0.2;
	
	private static final double DEFAULT_LATITUDE_CHANGE = 10;
	private static final double DEFAULT_LONGITUDE_CHANGE = 5;	
	
	private static final double DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE = Math.toRadians(60);
	private static final double DEFAULT_ANGLE_IN_RADIANS_QUADRANT_TWO = Math.toRadians(170);
	private static final double DEFAULT_ANGLE_IN_RADIANS_QUADRANT_THREE = Math.toRadians(195);
	private static final double DEFAULT_ANGLE_IN_RADIANS_QUADRANT_FOUR = Math.toRadians(340);
	
	private static final double DEFAULT_NEGATIVE_ANGLE_IN_RADIANS = -1;
	
	private static final double DEFAULT_SMALL_RADIAN_CHANGE = 0.1;
	private static final double DEFAULT_MEDIUM_RADIAN_CHANGE = 0.2;
	private static final double DEFAULT_LARGE_RADIAN_CHANGE = 0.4;
	
	private static final int DEFAULT_NEGATIVE_NUMBER = -5;
	
	private static final double ERROR_MARGIN_FOR_DOUBLES = 0.05;
	
	private static final int KM_PER_LATITUDE = 111;
	private static final double KM_TO_LONGITUDE_FACTOR = 111.320;
	
	
	private static final GeoCalculator CALCULATOR = new GeoCalculator();
	
	
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
		double bearingInRad = (Math.atan2(y,x) + TAO)% TAO;
		
		return bearingInRad;
	}

	private LatLng calculateNewPoint(LatLng startPoint, double bearingInRadians) {
		double latitudeEnd = startPoint.lat + Math.sin(bearingInRadians)/KM_PER_LATITUDE;
		double kmPerLongitude = Math.cos(Math.toRadians(startPoint.lat))*KM_TO_LONGITUDE_FACTOR;
		double longitudeEnd = startPoint.lng + Math.cos(bearingInRadians)/kmPerLongitude;
		return new LatLng(latitudeEnd,longitudeEnd);
	}
	
	//getPointWithinDistanceFrom
	@Test
	void getPointWithinDistanceFromReturnsPointWithRightDistanceAndAngleQuadrantOne() {
		LatLng startPoint = DEFAULT_LATLNG;
		LatLng otherPoint = CALCULATOR.getPointWithinDistanceFrom(startPoint, DEFAULT_DISTANCE_IN_KM, DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE);
		assertEquals(DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE, calculateAngleBetweenInRadians(startPoint, otherPoint), ERROR_MARGIN_FOR_DOUBLES);
		assertEquals(DEFAULT_DISTANCE_IN_KM, calculateDistanceBetweenInKm(startPoint, otherPoint), ERROR_MARGIN_FOR_DOUBLES);
	}
	
	@Test
	void getPointWithinDistanceFromReturnsPointWithRightDistanceAndAngleQuadrantTwo() {
		LatLng startPoint = DEFAULT_LATLNG;
		LatLng otherPoint = CALCULATOR.getPointWithinDistanceFrom(startPoint, DEFAULT_DISTANCE_IN_KM, DEFAULT_ANGLE_IN_RADIANS_QUADRANT_TWO);
		assertEquals(DEFAULT_ANGLE_IN_RADIANS_QUADRANT_TWO, calculateAngleBetweenInRadians(startPoint, otherPoint),ERROR_MARGIN_FOR_DOUBLES);
		assertEquals(DEFAULT_DISTANCE_IN_KM, calculateDistanceBetweenInKm(startPoint, otherPoint), ERROR_MARGIN_FOR_DOUBLES);
	}
	
	@Test
	void getPointWithinDistanceFromReturnsPointWithRightDistanceAndAngleQuadrantThree() {
		LatLng startPoint = DEFAULT_LATLNG;
		LatLng otherPoint = CALCULATOR.getPointWithinDistanceFrom(startPoint, DEFAULT_DISTANCE_IN_KM, DEFAULT_ANGLE_IN_RADIANS_QUADRANT_THREE);
		assertEquals(DEFAULT_ANGLE_IN_RADIANS_QUADRANT_THREE, calculateAngleBetweenInRadians(startPoint, otherPoint), ERROR_MARGIN_FOR_DOUBLES);
		assertEquals(DEFAULT_DISTANCE_IN_KM, calculateDistanceBetweenInKm(startPoint, otherPoint), ERROR_MARGIN_FOR_DOUBLES);
	}
	
	@Test
	void getPointWithinDistanceFromReturnsPointWithRightDistanceAndAngleQuadrantFour() {
		LatLng startPoint = DEFAULT_LATLNG;
		LatLng otherPoint = CALCULATOR.getPointWithinDistanceFrom(startPoint, DEFAULT_DISTANCE_IN_KM, DEFAULT_ANGLE_IN_RADIANS_QUADRANT_FOUR);
		assertEquals(DEFAULT_ANGLE_IN_RADIANS_QUADRANT_FOUR, calculateAngleBetweenInRadians(startPoint, otherPoint), ERROR_MARGIN_FOR_DOUBLES);
		assertEquals(DEFAULT_DISTANCE_IN_KM, calculateDistanceBetweenInKm(startPoint, otherPoint), ERROR_MARGIN_FOR_DOUBLES);
	}
	
	@Test
	void getPointWithinDistanceFromReturnsPointWithRightDistanceAndAngleForSmallDistance() {
		LatLng startPoint = DEFAULT_LATLNG;
		LatLng otherPoint = CALCULATOR.getPointWithinDistanceFrom(startPoint, DEFAULT_SMALL_DISTANCE, DEFAULT_ANGLE_IN_RADIANS_QUADRANT_FOUR);
		assertEquals(DEFAULT_ANGLE_IN_RADIANS_QUADRANT_FOUR, calculateAngleBetweenInRadians(startPoint, otherPoint), ERROR_MARGIN_FOR_DOUBLES);
		assertEquals(DEFAULT_SMALL_DISTANCE, calculateDistanceBetweenInKm(startPoint, otherPoint), ERROR_MARGIN_FOR_DOUBLES);
	}
	
	@Test
	void getPointWithinDistanceFromReturnsPointWithRightDistanceAndAngleForLargeDistance() {
		LatLng startPoint = DEFAULT_LATLNG;
		LatLng otherPoint = CALCULATOR.getPointWithinDistanceFrom(startPoint, DEFAULT_LARGE_DISTANCE, DEFAULT_ANGLE_IN_RADIANS_QUADRANT_FOUR);
		assertEquals(DEFAULT_ANGLE_IN_RADIANS_QUADRANT_FOUR, calculateAngleBetweenInRadians(startPoint, otherPoint), ERROR_MARGIN_FOR_DOUBLES);
		assertEquals(DEFAULT_LARGE_DISTANCE, calculateDistanceBetweenInKm(startPoint, otherPoint), ERROR_MARGIN_FOR_DOUBLES);
	}
	
	@Test
	void getPointWithinDistanceFromReturnsSamePointIfDistanceIsZero() {
		LatLng startPoint = DEFAULT_LATLNG;
		LatLng otherPoint = CALCULATOR.getPointWithinDistanceFrom(startPoint, 0, DEFAULT_ANGLE_IN_RADIANS_QUADRANT_FOUR);
		assertEquals(startPoint, otherPoint);
	}
	
	@Test
	void getPointWithinDistanceFromReturnsCorrectAngleAndDistanceForAngleBiggerThan2Pi() {
		LatLng startPoint = DEFAULT_LATLNG;
		LatLng otherPoint = CALCULATOR.getPointWithinDistanceFrom(startPoint, DEFAULT_DISTANCE_IN_KM, DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE +TAO);
		assertEquals(DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE, calculateAngleBetweenInRadians(startPoint, otherPoint), ERROR_MARGIN_FOR_DOUBLES);
		assertEquals(DEFAULT_DISTANCE_IN_KM, calculateDistanceBetweenInKm(startPoint, otherPoint), ERROR_MARGIN_FOR_DOUBLES);
	}
	
	@Test
	void getPointWithinDistanceFromReturnsCorrectAngleAndDistanceForNegativeAngles() {
		LatLng startPoint = DEFAULT_LATLNG;
		LatLng otherPoint = CALCULATOR.getPointWithinDistanceFrom(startPoint, DEFAULT_DISTANCE_IN_KM, -DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE);
		assertEquals(TAO - DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE, calculateAngleBetweenInRadians(startPoint, otherPoint), ERROR_MARGIN_FOR_DOUBLES);
		assertEquals(DEFAULT_DISTANCE_IN_KM, calculateDistanceBetweenInKm(startPoint, otherPoint), ERROR_MARGIN_FOR_DOUBLES);
	}
	
	@Test
	void getPointWithinDistanceFromThrowsIAEOnNegativeDistance() {
		LatLng startPoint = DEFAULT_LATLNG;
		assertThrows(IllegalArgumentException.class, ()->{
			CALCULATOR.getPointWithinDistanceFrom(startPoint, DEFAULT_NEGATIVE_NUMBER, DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE);
		});
	}
	
	@Test
	void getPointWithinDistanceFromThrowsIAEIfstartPointIsNull() {
		LatLng startPoint = null;
		assertThrows(IllegalArgumentException.class, ()->{
			CALCULATOR.getPointWithinDistanceFrom(startPoint, DEFAULT_DISTANCE_IN_KM, DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE);
		});
	}
	
	//getBearingInRadians

	@Test
	void getBearingInRadiansReturnsHalfPIWhenOnlyLatitudeIncrease() {
		LatLng startpoint = DEFAULT_LATLNG;
		LatLng endPoint = new LatLng(DEFAULT_LATITUDE+DEFAULT_LATITUDE_CHANGE, DEFAULT_LONGITUDE);
		assertEquals(Math.PI/2, CALCULATOR.getBearingInRadians(startpoint, endPoint), ERROR_MARGIN_FOR_DOUBLES);
	}
	
	@Test
	void getBearingInRadiansReturnsOneAndAHalfPIWhenOnlyLatitudeDecrease() {
		LatLng startpoint = DEFAULT_LATLNG;
		LatLng endPoint = new LatLng(DEFAULT_LATITUDE-DEFAULT_LATITUDE_CHANGE, DEFAULT_LONGITUDE);
		assertEquals(1.5 *Math.PI, CALCULATOR.getBearingInRadians(startpoint, endPoint), ERROR_MARGIN_FOR_DOUBLES);
	}
	
	@Test
	void getBearingInRadiansReturnsZeroWhenOnlyLongitudeIncrease() {
		LatLng startpoint = DEFAULT_LATLNG;
		LatLng endPoint = new LatLng(DEFAULT_LATITUDE, DEFAULT_LONGITUDE+DEFAULT_LONGITUDE_CHANGE);
		assertEquals(0, CALCULATOR.getBearingInRadians(startpoint, endPoint), ERROR_MARGIN_FOR_DOUBLES);
	}
	
	@Test
	void getBearingInRadiansReturnsPIWhenOnlyLongitudeDecrease() {
		LatLng startpoint = DEFAULT_LATLNG;
		LatLng endPoint = new LatLng(DEFAULT_LATITUDE, DEFAULT_LONGITUDE-DEFAULT_LONGITUDE_CHANGE);
		assertEquals(Math.PI, CALCULATOR.getBearingInRadians(startpoint, endPoint), ERROR_MARGIN_FOR_DOUBLES);
	}
	
	@Test
	void getBearingInRadiansReturnsZeroWhenStartPointAndEndPointSame() {
		LatLng startpoint = DEFAULT_LATLNG;
		assertEquals(0, CALCULATOR.getBearingInRadians(startpoint, startpoint), ERROR_MARGIN_FOR_DOUBLES);
	}
	
	@Test
	void getBearingInRadiansReturnsReturnsCorrectResultWhenEndPointInQuadrantOne() {
		LatLng startpoint = DEFAULT_LATLNG;
		LatLng endPoint = calculateNewPoint(startpoint, DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE);
		assertEquals(DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE, CALCULATOR.getBearingInRadians(startpoint, endPoint), ERROR_MARGIN_FOR_DOUBLES);
	}

	@Test
	void getBearingInRadiansReturnsReturnsCorrectResultWhenEndPointInQuadrantTwo() {
		LatLng startpoint = DEFAULT_LATLNG;
		LatLng endPoint = calculateNewPoint(startpoint, DEFAULT_ANGLE_IN_RADIANS_QUADRANT_TWO);
		assertEquals(DEFAULT_ANGLE_IN_RADIANS_QUADRANT_TWO, CALCULATOR.getBearingInRadians(startpoint, endPoint), ERROR_MARGIN_FOR_DOUBLES);
	}
	
	@Test
	void getBearingInRadiansReturnsReturnsCorrectResultWhenEndPointInQuadrantThree() {
		LatLng startpoint = DEFAULT_LATLNG;
		LatLng endPoint = calculateNewPoint(startpoint, DEFAULT_ANGLE_IN_RADIANS_QUADRANT_THREE);
		assertEquals(DEFAULT_ANGLE_IN_RADIANS_QUADRANT_THREE, CALCULATOR.getBearingInRadians(startpoint, endPoint), ERROR_MARGIN_FOR_DOUBLES);
	}
	
	@Test
	void getBearingInRadiansReturnsReturnsCorrectResultWhenEndPointInQuadrantFour() {
		LatLng startpoint = DEFAULT_LATLNG;
		LatLng endPoint = calculateNewPoint(startpoint, DEFAULT_ANGLE_IN_RADIANS_QUADRANT_FOUR);
		assertEquals(DEFAULT_ANGLE_IN_RADIANS_QUADRANT_FOUR, CALCULATOR.getBearingInRadians(startpoint, endPoint), ERROR_MARGIN_FOR_DOUBLES);
	}
	
	@Test
	void getBearingInRadiansThrowsIAEIfStartPointIsNull() {
		LatLng startpoint = null;
		LatLng endPoint = DEFAULT_LATLNG;
		assertThrows(IllegalArgumentException.class, () -> {CALCULATOR.getBearingInRadians(startpoint, endPoint);});
	}
	
	@Test
	void getBearingInRadiansThrowsIAEIfEndPointIsNull() {
		LatLng startPoint = DEFAULT_LATLNG;
		LatLng endPoint = null;
		assertThrows(IllegalArgumentException.class, () -> {CALCULATOR.getBearingInRadians(startPoint, endPoint);});
	}
	
	@Test
	void getPointWithClosestBearingReturnsNullIfListOfPlacesIsEmpty() {
		LatLng point = CALCULATOR.findPointWithClosestBearing(new ArrayList<LatLng>(), DEFAULT_LATLNG, DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE);
		assertNull(point); 
	}
	
	@Test
	void getPointWithClosestBearingThrowsIAEIfListOfPlacesIsNull() {
		assertThrows(IllegalArgumentException.class, ()-> {
			CALCULATOR.findPointWithClosestBearing(null, DEFAULT_LATLNG, DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE);
		});
	}
	@Test
	void getPointWithClosestBearingThrowsIAEIfStartPointIsNull() {
		ArrayList<LatLng> places = new ArrayList<>();
		places.add(DEFAULT_LATLNG);
		assertThrows(IllegalArgumentException.class, ()-> {
			CALCULATOR.findPointWithClosestBearing(places, null ,DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE);
		});
	}
	
	@Test
	void getPointWithClosestIdentifiesCorrectPointIfItIsFirstInListAndLargerThanGoalBearing() {
		LatLng closestPoint = calculateNewPoint(DEFAULT_LATLNG, DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE + DEFAULT_SMALL_RADIAN_CHANGE);
		LatLng mediumClosePoint = calculateNewPoint(DEFAULT_LATLNG, DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE + DEFAULT_MEDIUM_RADIAN_CHANGE);
		LatLng mostDistantPoint = calculateNewPoint(DEFAULT_LATLNG, DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE + DEFAULT_LARGE_RADIAN_CHANGE);
		ArrayList<LatLng> places = new ArrayList<>();
		places.add(closestPoint);
		places.add(mediumClosePoint);
		places.add(mostDistantPoint);
		assertEquals(closestPoint,CALCULATOR.findPointWithClosestBearing(places, DEFAULT_LATLNG ,DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE));
	}
	
	@Test
	void getPointWithClosestIdentifiesCorrectPointIfItIsInTheMiddleOfTheListAndLargerThanGoalBearing() {
		LatLng closestPoint = calculateNewPoint(DEFAULT_LATLNG, DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE + DEFAULT_SMALL_RADIAN_CHANGE);
		LatLng mediumClosePoint = calculateNewPoint(DEFAULT_LATLNG, DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE + DEFAULT_MEDIUM_RADIAN_CHANGE);
		LatLng mostDistantPoint = calculateNewPoint(DEFAULT_LATLNG, DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE + DEFAULT_LARGE_RADIAN_CHANGE);
		ArrayList<LatLng> places = new ArrayList<>();
		places.add(mediumClosePoint);
		places.add(closestPoint);
		places.add(mostDistantPoint);
		assertEquals(closestPoint,CALCULATOR.findPointWithClosestBearing(places, DEFAULT_LATLNG ,DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE));
	}
	
	@Test
	void getPointWithClosestIdentifiesCorrectPointIfItIsLastInTheListAndLargerThanGoalBearing() {
		LatLng closestPoint = calculateNewPoint(DEFAULT_LATLNG, DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE + DEFAULT_SMALL_RADIAN_CHANGE);
		LatLng mediumClosePoint = calculateNewPoint(DEFAULT_LATLNG, DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE + DEFAULT_MEDIUM_RADIAN_CHANGE);
		LatLng mostDistantPoint = calculateNewPoint(DEFAULT_LATLNG, DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE + DEFAULT_LARGE_RADIAN_CHANGE);
		ArrayList<LatLng> places = new ArrayList<>();
		places.add(mediumClosePoint);
		places.add(mostDistantPoint);
		places.add(closestPoint);
		assertEquals(closestPoint,CALCULATOR.findPointWithClosestBearing(places, DEFAULT_LATLNG ,DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE));
	}
	
	@Test
	void getPointWithClosestIdentifiesCorrectPointIfItIsSmallerThanGoalBearing() {
		LatLng closestPoint = calculateNewPoint(DEFAULT_LATLNG, DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE - DEFAULT_SMALL_RADIAN_CHANGE);
		LatLng mediumClosePoint = calculateNewPoint(DEFAULT_LATLNG, DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE + DEFAULT_MEDIUM_RADIAN_CHANGE);
		LatLng mostDistantPoint = calculateNewPoint(DEFAULT_LATLNG, DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE + DEFAULT_LARGE_RADIAN_CHANGE);
		ArrayList<LatLng> places = new ArrayList<>();
		places.add(mediumClosePoint);
		places.add(mostDistantPoint);
		places.add(closestPoint);
		assertEquals(closestPoint,CALCULATOR.findPointWithClosestBearing(places, DEFAULT_LATLNG ,DEFAULT_ANGLE_IN_RADIANS_QUADRANT_ONE));
	}
	
	@Test
	void getPointWithClosestIdentifiesCorrectPointIfGoalBearingIsNegative() {
		LatLng closestPoint = calculateNewPoint(DEFAULT_LATLNG, DEFAULT_NEGATIVE_ANGLE_IN_RADIANS - DEFAULT_SMALL_RADIAN_CHANGE);
		LatLng mediumClosePoint = calculateNewPoint(DEFAULT_LATLNG, DEFAULT_NEGATIVE_ANGLE_IN_RADIANS + DEFAULT_MEDIUM_RADIAN_CHANGE);
		LatLng mostDistantPoint = calculateNewPoint(DEFAULT_LATLNG, DEFAULT_NEGATIVE_ANGLE_IN_RADIANS + DEFAULT_LARGE_RADIAN_CHANGE);
		ArrayList<LatLng> places = new ArrayList<>();
		places.add(mediumClosePoint);
		places.add(mostDistantPoint);
		places.add(closestPoint);
		assertEquals(closestPoint,CALCULATOR.findPointWithClosestBearing(places, DEFAULT_LATLNG ,DEFAULT_NEGATIVE_ANGLE_IN_RADIANS));
	}
	
	@Test
	void getPointWithClosestIdentifiesCorrectPointIfGoalBearingIsLargerThan2Pi() {
		LatLng closestPoint = calculateNewPoint(DEFAULT_LATLNG, TAO+1 - DEFAULT_SMALL_RADIAN_CHANGE);
		LatLng mediumClosePoint = calculateNewPoint(DEFAULT_LATLNG, TAO+1 + DEFAULT_MEDIUM_RADIAN_CHANGE);
		LatLng mostDistantPoint = calculateNewPoint(DEFAULT_LATLNG, TAO+1 + DEFAULT_LARGE_RADIAN_CHANGE);
		ArrayList<LatLng> places = new ArrayList<>();
		places.add(mediumClosePoint);
		places.add(mostDistantPoint);
		places.add(closestPoint);
		assertEquals(closestPoint,CALCULATOR.findPointWithClosestBearing(places, DEFAULT_LATLNG ,TAO+1));
	}
	
	@Test
	void getPointWithClosestIdentifiesCorrectPointIfClosestPointIsCloseOnOtherSideOf0() {
		LatLng closestPoint = calculateNewPoint(DEFAULT_LATLNG, TAO - 0.01);
		LatLng mediumClosePoint = calculateNewPoint(DEFAULT_LATLNG, TAO - 0.02);
		LatLng mostDistantPoint = calculateNewPoint(DEFAULT_LATLNG, TAO - 0.03);
		ArrayList<LatLng> places = new ArrayList<>();
		places.add(mediumClosePoint);
		places.add(mostDistantPoint);
		places.add(closestPoint);
		assertEquals(closestPoint,CALCULATOR.findPointWithClosestBearing(places, DEFAULT_LATLNG ,0.01));
	}
	

}
