package group75.walkInProgress.route;

import static org.junit.jupiter.api.Assertions.*;

import java.util.ArrayList;
import java.util.List;

import org.junit.jupiter.api.Test;

import com.google.maps.model.DirectionsRoute;
import com.google.maps.model.DirectionsLeg;
import com.google.maps.model.DirectionsStep;
import com.google.maps.model.EncodedPolyline;
import com.google.maps.model.Distance;
import com.google.maps.model.Duration;
import com.google.maps.model.Bounds;
import com.google.maps.model.LatLng;

class RouteTest {
	
	private static final LatLng DEFAULT_LATLNG = new LatLng(50.5, 17.3);
	private static final LatLng OTHER_LATLNG = new LatLng(55.7, 19.6);
	private static final LatLng ONE_MORE_LATLNG = new LatLng(60.7, 40.8);
	private static final double ERROR_MARGIN_FOR_DOUBLES = 0.05;
	
	private static DirectionsRoute getDummyDirectionsRoute() {
		DirectionsRoute route = new DirectionsRoute();
		route.bounds = new Bounds();
		DirectionsLeg legs[] = {};
		route.legs = legs;
		return route;
	}
	
	private static List<LatLng> setupWayPoints() {
		List<LatLng> waypoints = new ArrayList<LatLng>();

		waypoints.add(new LatLng(10, 15));
		waypoints.add(new LatLng(20, 30));
		waypoints.add(new LatLng(40, 50));
		return waypoints;
	}
	
	private static List<LatLng> getDefaultPolyLines1() {
		List<LatLng> polyLines = new ArrayList<LatLng>();
		polyLines.add(new LatLng(1,2));
		polyLines.add(new LatLng(3,4));
		polyLines.add(new LatLng(5,6));
		return polyLines;
	}
	
	private static List<LatLng> getDefaultPolyLines2() {
		List<LatLng> polyLines = new ArrayList<LatLng>();
		polyLines.add(new LatLng(11,12));
		polyLines.add(new LatLng(13,14));
		polyLines.add(new LatLng(15,16));
		return polyLines;
	}
	
	private static List<LatLng> getDefaultPolyLines3() {
		List<LatLng> polyLines = new ArrayList<LatLng>();
		polyLines.add(new LatLng(21,22));
		polyLines.add(new LatLng(23,24));
		polyLines.add(new LatLng(25,26));
		return polyLines;
	}
	
	private static List<LatLng> getDefaultPolyLines4() {
		List<LatLng> polyLines = new ArrayList<LatLng>();
		polyLines.add(new LatLng(31,32));
		polyLines.add(new LatLng(33,34));
		polyLines.add(new LatLng(35,36));
		return polyLines;
	}
	
	private static List<LatLng> getDefaultPolyLines5() {
		List<LatLng> polyLines = new ArrayList<LatLng>();
		polyLines.add(new LatLng(41,42));
		polyLines.add(new LatLng(43,44));
		polyLines.add(new LatLng(45,46));
		return polyLines;
	}
	
	private static List<LatLng> getDefaultPolyLines6() {
		List<LatLng> polyLines = new ArrayList<LatLng>();
		polyLines.add(new LatLng(51,52));
		polyLines.add(new LatLng(53,54));
		polyLines.add(new LatLng(55,56));
		return polyLines;
	}
	
	private static DirectionsStep setUpDirectionsStep(int distanceInMeters, int durationInSeconds, String htmlInstructions, List<LatLng> polylines) {
		DirectionsStep step = new DirectionsStep();
		step.distance = new Distance();
		step.distance.inMeters = distanceInMeters;
		step.duration = new Duration();
		step.duration.inSeconds = durationInSeconds;
		step.htmlInstructions = htmlInstructions;
		step.polyline = new EncodedPolyline(polylines);
		return step;
	}
	
	private static DirectionsLeg setUpDirectionsLeg(DirectionsStep... steps) {
		DirectionsLeg leg = new DirectionsLeg();
		leg.steps = steps;
		return leg;
	}
	

	@Test
	void constuctorSetsBoundsFromDirectionsRoute() throws RouteException {
		DirectionsRoute dRoute = getDummyDirectionsRoute();
		dRoute.bounds.northeast = OTHER_LATLNG;
		dRoute.bounds.southwest = ONE_MORE_LATLNG;
		Route route = new Route(dRoute, new ArrayList<LatLng>(), DEFAULT_LATLNG);
		assertEquals(OTHER_LATLNG, route.getNorthEastBound());
		assertEquals(ONE_MORE_LATLNG, route.getSouthWestBound());
	}
	
	@Test
	void constuctorSetsSpecifiedWayPoints() throws RouteException {
		DirectionsRoute dRoute = getDummyDirectionsRoute();
		Route route = new Route(dRoute, setupWayPoints(), DEFAULT_LATLNG);
		assertEquals(setupWayPoints(), route.getWaypoints());
	}
	
	@Test
	void constuctorSetsSpecifiedStartPoint() throws RouteException {
		DirectionsRoute dRoute = getDummyDirectionsRoute();
		Route route = new Route(dRoute, new ArrayList<LatLng>(), DEFAULT_LATLNG);
		assertEquals(DEFAULT_LATLNG, route.getStartPoint());
	}
	
	@Test
	void constuctorSetsPolyCoordinatesFromDirectionsRoute() throws RouteException {
		DirectionsRoute dRoute = getDummyDirectionsRoute();
		DirectionsLeg legs[] = {
			setUpDirectionsLeg(
					setUpDirectionsStep(0, 0, "", getDefaultPolyLines1()),
					setUpDirectionsStep(0, 0, "", getDefaultPolyLines2())
					),
			setUpDirectionsLeg(
					setUpDirectionsStep(0, 0, "", getDefaultPolyLines3()),
					setUpDirectionsStep(0, 0, "", getDefaultPolyLines4())
					),
			setUpDirectionsLeg(
					setUpDirectionsStep(0, 0, "", getDefaultPolyLines5()),
					setUpDirectionsStep(0, 0, "", getDefaultPolyLines6())
					)
		};
		dRoute.legs = legs;
		List<LatLng> expectedPolyLines = new ArrayList<>();
		expectedPolyLines.addAll(getDefaultPolyLines1());
		expectedPolyLines.addAll(getDefaultPolyLines2());
		expectedPolyLines.addAll(getDefaultPolyLines3());
		expectedPolyLines.addAll(getDefaultPolyLines4());
		expectedPolyLines.addAll(getDefaultPolyLines5());
		expectedPolyLines.addAll(getDefaultPolyLines6());
		Route route = new Route(dRoute, new ArrayList<LatLng>(), DEFAULT_LATLNG);
		List<LatLng> actualPolylines = route.getPolyCoordinates();
		assertEquals(expectedPolyLines.size(), actualPolylines.size());
		for(int i = 0; i<expectedPolyLines.size(); i++) {
			assertEquals(expectedPolyLines.get(i).lat, actualPolylines.get(i).lat, ERROR_MARGIN_FOR_DOUBLES);
			assertEquals(expectedPolyLines.get(i).lng, actualPolylines.get(i).lng, ERROR_MARGIN_FOR_DOUBLES);
		}
	}
	
	@Test
	void constuctorCalculatesDurationCorrectly() throws RouteException {
		DirectionsRoute dRoute = getDummyDirectionsRoute();
		DirectionsLeg legs[] = {
			setUpDirectionsLeg(
					setUpDirectionsStep(0, 10, "", new ArrayList<LatLng>()),
					setUpDirectionsStep(0, 20, "", new ArrayList<LatLng>())
					),
			setUpDirectionsLeg(
					setUpDirectionsStep(0, 30, "", new ArrayList<LatLng>()),
					setUpDirectionsStep(0, 40, "", new ArrayList<LatLng>())
					),
			setUpDirectionsLeg(
					setUpDirectionsStep(0, 50, "", new ArrayList<LatLng>()),
					setUpDirectionsStep(0, 60, "", new ArrayList<LatLng>())
					)
		};
		dRoute.legs = legs;
		Route route = new Route(dRoute, new ArrayList<LatLng>(), DEFAULT_LATLNG);
		int expectedDuration = 10+20+30+40+50+60;
		assertEquals(expectedDuration, route.getDurationInSeconds());
	}
	
	@Test
	void constuctorCalculatesDistanceCorrectly() throws RouteException {
		DirectionsRoute dRoute = getDummyDirectionsRoute();
		DirectionsLeg legs[] = {
			setUpDirectionsLeg(
					setUpDirectionsStep(10,0,  "", new ArrayList<LatLng>()),
					setUpDirectionsStep(20,0,  "", new ArrayList<LatLng>())
					),
			setUpDirectionsLeg(
					setUpDirectionsStep(30, 0, "", new ArrayList<LatLng>()),
					setUpDirectionsStep(40, 0, "", new ArrayList<LatLng>())
					),
			setUpDirectionsLeg(
					setUpDirectionsStep(50, 0, "", new ArrayList<LatLng>()),
					setUpDirectionsStep(60, 0, "", new ArrayList<LatLng>())
					)
		};
		dRoute.legs = legs;
		Route route = new Route(dRoute, new ArrayList<LatLng>(), DEFAULT_LATLNG);
		int expectedDistance = 10+20+30+40+50+60;
		assertEquals(expectedDistance, route.getDistance());
	}
	
	@Test
	void constuctorThrowsRouteExceptionIfStepContainsWordFerryInLowerCase() throws RouteException {
		DirectionsRoute dRoute = getDummyDirectionsRoute();
		DirectionsLeg legs[] = {
			setUpDirectionsLeg(
					setUpDirectionsStep(0 , 0,  "this step has a ferry in it's instruction", new ArrayList<LatLng>())
					),
		};
		dRoute.legs = legs;
		assertThrows(RouteException.class, ()-> {new Route(dRoute, new ArrayList<LatLng>(), DEFAULT_LATLNG);});
	}
	
	@Test
	void constuctorThrowsRouteExceptionIfStepContainsWordFerryInMixedCase() throws RouteException {
		DirectionsRoute dRoute = getDummyDirectionsRoute();
		DirectionsLeg legs[] = {
			setUpDirectionsLeg(
					setUpDirectionsStep(0 , 0,  "this step has a feRRy in it's instruction", new ArrayList<LatLng>())
					),
		};
		dRoute.legs = legs;
		assertThrows(RouteException.class, ()-> {new Route(dRoute, new ArrayList<LatLng>(), DEFAULT_LATLNG);});
	}
	
	@Test
	void constuctorThrowsRouteExceptionIfStepContainsWordFerryInUpperCase() throws RouteException {
		DirectionsRoute dRoute = getDummyDirectionsRoute();
		DirectionsLeg legs[] = {
			setUpDirectionsLeg(
					setUpDirectionsStep(0 , 0,  "this step has a FERRY in it's instruction", new ArrayList<LatLng>())
					),
		};
		dRoute.legs = legs;
		assertThrows(RouteException.class, ()-> {new Route(dRoute, new ArrayList<LatLng>(), DEFAULT_LATLNG);});
	}


}
