package group75.walkInProgress.route;

import static org.junit.jupiter.api.Assertions.*;


import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Arrays;

import org.junit.jupiter.api.Test;


import com.google.maps.NearbySearchRequest;
import com.google.maps.errors.ApiException;
import com.google.maps.model.Geometry;
import com.google.maps.model.LatLng;
import com.google.maps.model.PlaceType;
import com.google.maps.model.PlacesSearchResponse;
import com.google.maps.model.PlacesSearchResult;

class RouteGeneratorTest {
	private static final double DEFAULT_LATITUDE = 58.21;
	private static final double DEFAULT_LONGITUDE = 17.34;
	private static final double DEFAULT_DURATION_IN_MINUTES = 40;
	private static final double MINUTES_PER_HOUR = 60;
	private static final int KM_PER_HOUR_WALKING = 5;
	private static final double DEFAULT_WALK_DISTANCE = DEFAULT_DURATION_IN_MINUTES/MINUTES_PER_HOUR*KM_PER_HOUR_WALKING;
	private static final int KM_PER_LATITUDE = 111;
	private static final double KM_TO_LONGITUDE_FACTOR = 111.320;
	private static final double DEFAULT_ANGLE_IN_RADIANS = 1.2;
	private static final double SMALL_BEARING_CHANGE = 0.1;
	private static final double LARGER_BEARING_CHANGE = 0.3;
	private static final double DEFAULT_NEGATIVE_NUMBER = -1337;
	private static final LatLng DEFAULT_LATLNG = new LatLng(DEFAULT_LATITUDE, DEFAULT_LONGITUDE);
	private static final LatLng OTHER_LATLNG = new LatLng(1, 2);
	private static final PlaceType DEFAULT_PLACE_TYPE = PlaceType.PARK;
	private static final String DEFAULT_INVALID_PLACE_TYPE_NAME = "Obefintligtnamn";
	private static final int METERS_PER_KM = 1000;
	private static final double ERROR_MARGIN_FOR_DOUBLES = 0.05;

	private static List<LatLng> setupWayPoints() {
		List<LatLng> waypoints = new ArrayList<LatLng>();

		waypoints.add(new LatLng(10, 15));
		waypoints.add(new LatLng(20, 30));
		waypoints.add(new LatLng(40, 50));
		return waypoints;
	}

	private static RouteGenerator getGenerator() {
		return new RouteGenerator(DEFAULT_LATLNG, DEFAULT_DURATION_IN_MINUTES, DEFAULT_ANGLE_IN_RADIANS);
	}

	// Calculation from
	// https://stackoverflow.com/questions/3694380/calculating-distance-between-two-points-using-latitude-longitude
	private static double calculateDistanceBetweenInKm(LatLng point1, LatLng point2) {
		double lat1 = point1.lat;
		double lon1 = point1.lng;
		double lon2 = point2.lng;
		double lat2 = point2.lat;
		final int R = 6371; // Radius of the earth

		double latDistance = Math.toRadians(lat2 - lat1);
		double lonDistance = Math.toRadians(lon2 - lon1);
		double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2) + Math.cos(Math.toRadians(lat1))
				* Math.cos(Math.toRadians(lat2)) * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
		double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
		double distance = R * c;

		return distance;
	}

	private static double calculateAngleBetweenInRadians(LatLng point1, LatLng point2) {
		double lat1InRad = Math.toRadians(point1.lat);
		double lng1InRad = Math.toRadians(point1.lng);
		double lat2InRad = Math.toRadians(point2.lat);
		double lng2InRad = Math.toRadians(point2.lng);

		double longDiffInRad = lng2InRad - lng1InRad;
		double x = Math.sin(longDiffInRad) * Math.cos(lat2InRad);
		double y = Math.cos(lat1InRad) * Math.sin(lat2InRad)
				- Math.sin(lat1InRad) * Math.cos(lat2InRad) * Math.cos(longDiffInRad);
		double bearingInRad = (Math.atan2(y, x) + (2 * Math.PI)) % (Math.PI * 2);

		return bearingInRad;
	}

	private static LatLng calculateNewPoint(LatLng startPoint, double bearingInRadians) {
		double latitudeEnd = startPoint.lat + Math.sin(bearingInRadians)/KM_PER_LATITUDE;
		double kmPerLongitude = Math.cos(Math.toRadians(startPoint.lat))*KM_TO_LONGITUDE_FACTOR;
		double longitudeEnd = startPoint.lng + Math.cos(bearingInRadians)/kmPerLongitude;
		return new LatLng(latitudeEnd,longitudeEnd);
	}
	
	//Constructor
	@Test
	void constructorThrowsIAEIfStartPointIsNull() {
		assertThrows(IllegalArgumentException.class, ()-> {new RouteGenerator(null, DEFAULT_DURATION_IN_MINUTES, DEFAULT_ANGLE_IN_RADIANS);});
	}
	
	@Test
	void constructorThrowsIAEIfDurationIsNegative() {
		assertThrows(IllegalArgumentException.class, ()-> {new RouteGenerator(DEFAULT_LATLNG, DEFAULT_NEGATIVE_NUMBER, DEFAULT_ANGLE_IN_RADIANS);});
	}
	
	@Test
	void constructorCalculatesWalkDistanceFromDurationCorrrectly() {
		RouteGenerator generator = new RouteGenerator(DEFAULT_LATLNG, DEFAULT_DURATION_IN_MINUTES, DEFAULT_ANGLE_IN_RADIANS);
		double expectedWalkDistance = DEFAULT_DURATION_IN_MINUTES/MINUTES_PER_HOUR * KM_PER_HOUR_WALKING;
		assertEquals(expectedWalkDistance, generator.getWalkingDistanceInKm());
	}
	
	
	private static class FakeRouteGetter extends RouteGetter{
		LatLng givenStartPoint;
		List<LatLng> givenWayPoints;

		public FakeRouteGetter() {
			super();
			
		}
		@Override
		public
		Route getRoute(LatLng startPoint, List<LatLng> waypoints) {
			givenStartPoint = startPoint;
			givenWayPoints = waypoints;
			return null;
		}
		
		
	}
	
	//try to find route
	private static class RouteGeneratorWithFakeWayPointsAndRouteGetter extends RouteGenerator {
		double distanceRecievedByGenerateWaypoints;
		FakeRouteGetter getter;

		
		public RouteGeneratorWithFakeWayPointsAndRouteGetter(FakeRouteGetter getter) {
			super(DEFAULT_LATLNG, DEFAULT_DURATION_IN_MINUTES, DEFAULT_ANGLE_IN_RADIANS);
			this.getter = getter;
		}
		
		@Override
		RouteGetter getRouteGetter() {
			return getter;
		}
		
		@Override
		List<LatLng> generateWaypoints(double walkDistanceInKm) {
			distanceRecievedByGenerateWaypoints = walkDistanceInKm;
			return setupWayPoints();
		}
	}
	
	@Test 
    void tryToFindRouteUsesSpecifiedStartPointToCreateRoute() throws ApiException, InterruptedException, IOException, RouteException, TypeException {
		FakeRouteGetter getter = new FakeRouteGetter();
		RouteGeneratorWithFakeWayPointsAndRouteGetter generator = new RouteGeneratorWithFakeWayPointsAndRouteGetter(getter);
		generator.tryToFindRoute();
		assertEquals(DEFAULT_LATLNG, getter.givenStartPoint);
	}
	
	
	@Test 
    void tryToFindRouteSetsWayPointsToGeneratedWayPointsWhenNoTypeSet() throws ApiException, InterruptedException, IOException, RouteException {
		FakeRouteGetter getter = new FakeRouteGetter();
		RouteGeneratorWithFakeWayPointsAndRouteGetter generator = new RouteGeneratorWithFakeWayPointsAndRouteGetter(getter);
		generator.tryToFindRoute();
		assertEquals(setupWayPoints(), getter.givenWayPoints);
	}
	
	@Test 
    void tryToFindRouteSetsWayPointsToFirstPointWithPointOfInterestAndThenGeneratedWayPoints() throws ApiException, InterruptedException, IOException, RouteException, TypeException {
		FakeRouteGetter getter = new FakeRouteGetter();
		RouteGeneratorWithFakeWayPointsAndRouteGetter generator = new RouteGeneratorWithFakeWayPointsAndRouteGetter(getter) {
			@Override
			public List<LatLng> getPlacesNearby(double distanceInKm, PlaceType type) {
				List<LatLng> places = new ArrayList<>();
				places.add(OTHER_LATLNG);
				return places;
			}
		};
		generator.setTypeOfInterest(DEFAULT_PLACE_TYPE.toString());
		generator.tryToFindRoute();
		List<LatLng> expectedWaypoints = setupWayPoints();
		expectedWaypoints.add(0, OTHER_LATLNG);
		assertEquals(expectedWaypoints, getter.givenWayPoints);
	}
	
	@Test 
    void tryToFindRouteIncreasesNumberOfTries() throws ApiException, InterruptedException, IOException, RouteException, TypeException {
		FakeRouteGetter getter = new FakeRouteGetter();
		RouteGeneratorWithFakeWayPointsAndRouteGetter generator = new RouteGeneratorWithFakeWayPointsAndRouteGetter(getter);
		int numberOfTriesBefore = generator.getNumberOfTries();
		generator.tryToFindRoute();
		assertEquals(++numberOfTriesBefore, generator.getNumberOfTries());
	}
	
	@Test 
    void tryToFindRouteUsesCrowDistanceToGenerateWayPoints() throws ApiException, InterruptedException, IOException, RouteException, TypeException {
		FakeRouteGetter getter = new FakeRouteGetter();
		RouteGeneratorWithFakeWayPointsAndRouteGetter generator = new RouteGeneratorWithFakeWayPointsAndRouteGetter(getter);
		generator.tryToFindRoute();
		assertEquals(DEFAULT_WALK_DISTANCE*generator.getCrowFactor(), generator.distanceRecievedByGenerateWaypoints);
	}
	
	
	private static class RouteGeneratorWithFakeGetPlacesNearby extends RouteGenerator {
		List<LatLng> placesToReturnFromGetPlacesNearby;
		PlaceType typeSentToGetPlacesNearby;
		double distanceInKmSentToGetPlacesNearby;
		
		public RouteGeneratorWithFakeGetPlacesNearby (List<LatLng> placesToReturnFromGetPlacesNearby) {
			super(DEFAULT_LATLNG, DEFAULT_DURATION_IN_MINUTES, DEFAULT_ANGLE_IN_RADIANS);
			this.placesToReturnFromGetPlacesNearby = placesToReturnFromGetPlacesNearby;
		}
		
		@Override
		List<LatLng> getPlacesNearby(double distanceInKm, PlaceType type) throws ApiException ,InterruptedException ,IOException {
			typeSentToGetPlacesNearby = type;
			distanceInKmSentToGetPlacesNearby = distanceInKm;
			return placesToReturnFromGetPlacesNearby;
		};
	}
	//setTypeOfInterest
	@Test 
	void setTypeOfInterestInterpretsValidTypeInMixedCase() throws IOException, ApiException, InterruptedException, TypeException {
		RouteGeneratorWithFakeGetPlacesNearby generator = new RouteGeneratorWithFakeGetPlacesNearby(new ArrayList<LatLng>());
		generator.setTypeOfInterest(DEFAULT_PLACE_TYPE.toString().substring(0, 2).toUpperCase() + DEFAULT_PLACE_TYPE.toString().substring(2).toLowerCase());
		assertEquals(DEFAULT_PLACE_TYPE, generator.typeSentToGetPlacesNearby);
	}
	
	@Test 
	void setTypeOfInterestInterpretsValidTypeInUpperCase() throws IOException, ApiException, InterruptedException, TypeException {
		RouteGeneratorWithFakeGetPlacesNearby generator = new RouteGeneratorWithFakeGetPlacesNearby(new ArrayList<LatLng>());
		generator.setTypeOfInterest(DEFAULT_PLACE_TYPE.toString().toUpperCase());
		assertEquals(DEFAULT_PLACE_TYPE, generator.typeSentToGetPlacesNearby);
	}
	
	@Test 
	void setTypeOfInterestInterpretsValidTypeInLowerCase() throws IOException, ApiException, InterruptedException, TypeException {
		RouteGeneratorWithFakeGetPlacesNearby generator = new RouteGeneratorWithFakeGetPlacesNearby(new ArrayList<LatLng>());
		generator.setTypeOfInterest(DEFAULT_PLACE_TYPE.toString().toLowerCase());
		assertEquals(DEFAULT_PLACE_TYPE, generator.typeSentToGetPlacesNearby);
	}
	
	@Test 
	void setTypeOfInterestThrowsTypeExceptionWhithInvalidPlaceType() throws IOException, ApiException, InterruptedException, TypeException {
		RouteGeneratorWithFakeGetPlacesNearby generator = new RouteGeneratorWithFakeGetPlacesNearby(new ArrayList<LatLng>());
		assertThrows(TypeException.class, ()-> {generator.setTypeOfInterest(DEFAULT_INVALID_PLACE_TYPE_NAME);});
	}
	
	@Test 
	void setTypeOfInterestThrowsIAEIfTypeIsNull() throws IOException, ApiException, InterruptedException, TypeException {
		RouteGeneratorWithFakeGetPlacesNearby generator = new RouteGeneratorWithFakeGetPlacesNearby(new ArrayList<LatLng>());
		assertThrows(IllegalArgumentException.class, ()-> {generator.setTypeOfInterest(null);});
	}
	
	@Test
	void setTypeOfInterestSendsLegDistanceAsTheCrowFliesToGetPointsNearby() throws ApiException, InterruptedException, IOException, TypeException {
		RouteGeneratorWithFakeGetPlacesNearby generator = new RouteGeneratorWithFakeGetPlacesNearby(new ArrayList<LatLng>());
		generator.setTypeOfInterest(DEFAULT_PLACE_TYPE.toString());
		double expectedCrowDistance = DEFAULT_DURATION_IN_MINUTES/MINUTES_PER_HOUR * KM_PER_HOUR_WALKING * RouteGenerator.getDefaultRoadToCrowsFactor();
		double expectedLegDistance = expectedCrowDistance/RouteGenerator.getNumberOfLegs();
		assertEquals(expectedLegDistance, generator.distanceInKmSentToGetPlacesNearby);
	}
	
	@Test 
	void setTypeOfInterestDoesNotChangePointOfInterestIfNearBySearchWasEmpty() throws ApiException, InterruptedException, IOException, TypeException {
		RouteGeneratorWithFakeGetPlacesNearby generator = new RouteGeneratorWithFakeGetPlacesNearby(new ArrayList<LatLng>());
		LatLng pointOfInterestBefore = generator.getPointOfInterest();
		generator.setTypeOfInterest(DEFAULT_PLACE_TYPE.toString());
		assertEquals(pointOfInterestBefore, generator.getPointOfInterest());
	}
	
	@Test 
	void setTypeOfInterestDoesNotChangeBearingForFirstPointIfNearBySearchWasEmpty() throws ApiException, InterruptedException, IOException, TypeException {
		RouteGeneratorWithFakeGetPlacesNearby generator = new RouteGeneratorWithFakeGetPlacesNearby(new ArrayList<LatLng>());
		double bearingBefore = generator.getBearingToFirstPointInRadians();
		generator.setTypeOfInterest(DEFAULT_PLACE_TYPE.toString());
		assertEquals(bearingBefore, generator.getBearingToFirstPointInRadians());
	}
	
	@Test 
	void setTypeOfInterestSetsPointOfInterestToClosestPointInResultFromGetPlacesNearby() throws ApiException, InterruptedException, IOException, TypeException {
		List<LatLng> result = new ArrayList<>();
		LatLng closestPoint = calculateNewPoint(DEFAULT_LATLNG, DEFAULT_ANGLE_IN_RADIANS + SMALL_BEARING_CHANGE);
		result.add(closestPoint);
		result.add(calculateNewPoint(DEFAULT_LATLNG, DEFAULT_ANGLE_IN_RADIANS + LARGER_BEARING_CHANGE));
		RouteGeneratorWithFakeGetPlacesNearby generator = new RouteGeneratorWithFakeGetPlacesNearby(result);
		generator.setTypeOfInterest(DEFAULT_PLACE_TYPE.toString());
		assertEquals(closestPoint, generator.getPointOfInterest());
	}
	
	@Test 
	void setTypeOfInterestSetsBearingOfFirstPointToFoundPointOfInterest() throws ApiException, InterruptedException, IOException, TypeException {
		List<LatLng> result = new ArrayList<>();
		double bearingForClosestPoint = DEFAULT_ANGLE_IN_RADIANS + SMALL_BEARING_CHANGE;
		LatLng closestPoint = calculateNewPoint(DEFAULT_LATLNG, bearingForClosestPoint);
		result.add(closestPoint);
		result.add(calculateNewPoint(DEFAULT_LATLNG, DEFAULT_ANGLE_IN_RADIANS + LARGER_BEARING_CHANGE));
		RouteGeneratorWithFakeGetPlacesNearby generator = new RouteGeneratorWithFakeGetPlacesNearby(result);
		generator.setTypeOfInterest(DEFAULT_PLACE_TYPE.toString());
		assertEquals(bearingForClosestPoint, generator.getBearingToFirstPointInRadians(), ERROR_MARGIN_FOR_DOUBLES);
	}
	
	//getPlacesNearby
	private static class RouteGeneratorWithFakePlacesApiRequest extends RouteGenerator {

		FakeNearbySearchRequest request;
		
		public RouteGeneratorWithFakePlacesApiRequest(FakeNearbySearchRequest request) {
			super(DEFAULT_LATLNG, DEFAULT_DURATION_IN_MINUTES, DEFAULT_ANGLE_IN_RADIANS);
			this.request = request;
		}
		
		@Override
		NearbySearchRequest getNearbySearchRequest() {
			return request;
		}
		
		@Override
		PlacesSearchResponse sendNearbySearchRequest(NearbySearchRequest request) throws ApiException, InterruptedException, IOException {
			return ((FakeNearbySearchRequest)request).send();
			 
		}
	}
	
	private static class FakeNearbySearchRequest extends NearbySearchRequest {
		boolean sent;
		PlaceType type;
		int radius;
		PlacesSearchResult result[];
		
		public FakeNearbySearchRequest(PlacesSearchResult result[]) {
			super(null);
			this.result = result;
		}
		
		@Override
		public FakeNearbySearchRequest type(PlaceType type) {
			this.type = type;
			return this;
		}
		
		@Override
		public FakeNearbySearchRequest radius(int radiusInMeters) {
			this.radius = radiusInMeters;
			return this;
		}
		
		PlacesSearchResponse send() {
			sent = true;
			PlacesSearchResponse response = new PlacesSearchResponse();
			response.results = result;
			return response;
		}
	}
	
	@Test 
	void getPlacesNearbyCallsApiWithSpecifiedType() throws IOException, InterruptedException, ApiException {
		PlacesSearchResult results[] = {};
		FakeNearbySearchRequest request = new FakeNearbySearchRequest(results);
		RouteGeneratorWithFakePlacesApiRequest generator = new RouteGeneratorWithFakePlacesApiRequest(request);
		generator.getPlacesNearby(DEFAULT_WALK_DISTANCE, DEFAULT_PLACE_TYPE);
		assertEquals(DEFAULT_PLACE_TYPE,request.type);
	}
	
	@Test 
	void getPlacesNearbyCallsApiWithSpecifiedDistanceInMeters() throws IOException, InterruptedException, ApiException {
		PlacesSearchResult results[] = {};
		FakeNearbySearchRequest request = new FakeNearbySearchRequest(results);
		RouteGeneratorWithFakePlacesApiRequest generator = new RouteGeneratorWithFakePlacesApiRequest(request);
		generator.getPlacesNearby(DEFAULT_WALK_DISTANCE, DEFAULT_PLACE_TYPE);
		assertEquals((int)(DEFAULT_WALK_DISTANCE * METERS_PER_KM),request.radius);
	}
	
	@Test 
	void getPlacesNearbySendsRequest() throws IOException, InterruptedException, ApiException {
		PlacesSearchResult results[] = {};
		FakeNearbySearchRequest request = new FakeNearbySearchRequest(results);
		RouteGeneratorWithFakePlacesApiRequest generator = new RouteGeneratorWithFakePlacesApiRequest(request);
		generator.getPlacesNearby(DEFAULT_WALK_DISTANCE, DEFAULT_PLACE_TYPE);
		assertTrue(request.sent);
	}
	@Test 
	void getPlacesNearbyReturnsEmptyListIfNoResult() throws IOException, InterruptedException, ApiException {
		PlacesSearchResult results[] = {};
		FakeNearbySearchRequest request = new FakeNearbySearchRequest(results);
		RouteGeneratorWithFakePlacesApiRequest generator = new RouteGeneratorWithFakePlacesApiRequest(request);
		List<LatLng> places = generator.getPlacesNearby(DEFAULT_WALK_DISTANCE, DEFAULT_PLACE_TYPE);
		assertTrue(places.isEmpty());
	}
	
	@Test 
	void getPlacesNearbyReturnsListWithCorrectlyConvertedResultsToLatLong() throws IOException, InterruptedException, ApiException {
		PlacesSearchResult result1 = new PlacesSearchResult();
		ArrayList<LatLng> expectedPlaces = new ArrayList<>();
		result1.geometry = new Geometry();
		result1.geometry.location = DEFAULT_LATLNG;
		expectedPlaces.add(DEFAULT_LATLNG);
		PlacesSearchResult result2 = new PlacesSearchResult();
		result2.geometry = new Geometry();
		result2.geometry.location = OTHER_LATLNG;
		expectedPlaces.add(OTHER_LATLNG);
		PlacesSearchResult results[] = {result1, result2};
		FakeNearbySearchRequest request = new FakeNearbySearchRequest(results);
		RouteGeneratorWithFakePlacesApiRequest generator = new RouteGeneratorWithFakePlacesApiRequest(request);
		List<LatLng> places = generator.getPlacesNearby(DEFAULT_WALK_DISTANCE, DEFAULT_PLACE_TYPE);
		assertEquals(expectedPlaces, places);
	}
	
	//Generate WayPoints
	@Test
	void generateWayPointsGeneratesRightNumberOfWayPoints() {
		List<LatLng> waypoints = getGenerator().generateWaypoints(DEFAULT_WALK_DISTANCE);
		assertEquals(RouteGenerator.getNumberOfWaypointsToGenerate(), waypoints.size());
	}

	@Test
	void generateWayPointsGeneratesWaypointsWithTheRightWalkDistance() {
		List<LatLng> waypoints = getGenerator().generateWaypoints(DEFAULT_WALK_DISTANCE);
		double walkDistance = calculateDistanceBetweenInKm(DEFAULT_LATLNG, waypoints.get(0));
		for (int i = 0; i < waypoints.size() - 1; i++) {
			walkDistance += calculateDistanceBetweenInKm(waypoints.get(i), waypoints.get(i + 1));
		}
		walkDistance += calculateDistanceBetweenInKm(waypoints.get(waypoints.size() - 1), DEFAULT_LATLNG);
		assertEquals(DEFAULT_WALK_DISTANCE, walkDistance, ERROR_MARGIN_FOR_DOUBLES);
	}

	@Test
	void generateWayPointsGeneratesWaypointsWithTheRightAngleBetweenThem() {
		List<LatLng> waypoints = getGenerator().generateWaypoints(DEFAULT_WALK_DISTANCE);
		for (int i = 0; i < waypoints.size() - 1; i++) {
			double angleToCurrent = calculateAngleBetweenInRadians(DEFAULT_LATLNG, waypoints.get(i));
			double angleToNext = calculateAngleBetweenInRadians(DEFAULT_LATLNG, waypoints.get(i + 1));
			double angleDifference = (angleToNext - angleToCurrent + 2 * Math.PI) % (2 * Math.PI);
			assertEquals(RouteGenerator.getRadiansBetweenLegs(), angleDifference, ERROR_MARGIN_FOR_DOUBLES);
		}
	}

	@Test
	void generateWayPointsGeneratesFirstWaypointWithGivenAngle() {
		List<LatLng> waypoints = getGenerator().generateWaypoints(DEFAULT_WALK_DISTANCE);
		assertEquals(DEFAULT_ANGLE_IN_RADIANS, calculateAngleBetweenInRadians(DEFAULT_LATLNG, waypoints.get(0)),
				ERROR_MARGIN_FOR_DOUBLES);
	}

	@Test
	void generateWayPointsGeneratesOnlyCopiesOfStartpointIfWalkDistanceIsZero() {
		List<LatLng> waypoints = getGenerator().generateWaypoints(0);
		for (LatLng point : waypoints) {
			assertEquals(DEFAULT_LATLNG, point);
		}
	}

	@Test
	void generateWayPointsThrowsIAEOnNegativeWalkDistance() {
		assertThrows(IllegalArgumentException.class, () -> {
			getGenerator().generateWaypoints(DEFAULT_NEGATIVE_NUMBER);
		});
	}

	// increaseCrowFactor

	// TODO more tests
	@Test
	void increaseCrowFactorIncreasesCrowFactor() {
		RouteGenerator generator = getGenerator();
		double factorBefore = generator.getCrowFactor();
		double stepBefore = generator.getCrowStep();
		generator.increaseCrowFactor();
		assertEquals(factorBefore + stepBefore, generator.getCrowFactor());
	}

	@Test
	void increaseCrowFactorDoesNotModifyCrowStepIfHasNotBeenDecreased() {
		RouteGenerator generator = getGenerator();
		double stepBefore = generator.getCrowStep();
		generator.increaseCrowFactor();
		assertEquals(stepBefore, generator.getCrowStep());
	}

	@Test
	void increaseCrowFactorModifiesCrowStepIfHasBeenDecreased() {
		RouteGenerator generator = getGenerator();
		double stepBefore = generator.getCrowStep();
		generator.decreaseCrowFactor();
		generator.increaseCrowFactor();
		assertEquals(stepBefore / 2, generator.getCrowStep());
	}

	// decreaseCrowFactor
	@Test
	void decreaseCrowFactorDecreasesCrowFactor() {
		RouteGenerator generator = getGenerator();
		double factorBefore = generator.getCrowFactor();
		double stepBefore = generator.getCrowStep();
		generator.decreaseCrowFactor();
		assertEquals(factorBefore - stepBefore, generator.getCrowFactor());
	}

	@Test
	void decreaseCrowFactorDoesNotModifyCrowStepIfHasNotBeenIncreased() {
		RouteGenerator generator = getGenerator();
		double stepBefore = generator.getCrowStep();
		generator.decreaseCrowFactor();
		assertEquals(stepBefore, generator.getCrowStep());
	}

	@Test
	void decreaseCrowFactorModifiesCrowStepIfHasBeenIncreased() {
		RouteGenerator generator = getGenerator();
		double stepBefore = generator.getCrowStep();
		generator.increaseCrowFactor();
		generator.decreaseCrowFactor();
		assertEquals(stepBefore / 2, generator.getCrowStep());
	}

}
