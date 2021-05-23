package group75.walkInProgress.route;

import static org.junit.jupiter.api.Assertions.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.junit.jupiter.api.Test;

import com.google.maps.DirectionsApiRequest;
import com.google.maps.DirectionsApi.RouteRestriction;
import com.google.maps.errors.ApiException;
import com.google.maps.model.DirectionsResult;
import com.google.maps.model.LatLng;
import com.google.maps.model.TravelMode;



class RouteGetterTest {
	private static final LatLng DEFAULT_LATLNG = new LatLng(58.21, 17.34);
	
	private static List<LatLng> setupWayPoints() {
		List<LatLng> waypoints = new ArrayList<LatLng>();

		waypoints.add(new LatLng(10, 15));
		waypoints.add(new LatLng(20, 30));
		waypoints.add(new LatLng(40, 50));
		return waypoints;
	}
	
	private static class RouteGetterWithStoringDirectionsApi extends RouteGetter {

		StoringDirectionsApiRequest request;
		
		public RouteGetterWithStoringDirectionsApi(StoringDirectionsApiRequest request) {
			super();
			this.request = request;
		}
		
		@Override
		StoringDirectionsApiRequest getDirectionsRequest() {
			return request;
		}
		
		@Override
		DirectionsResult sendDirectionsRequest(DirectionsApiRequest request) throws ApiException, InterruptedException, IOException {
			return ((StoringDirectionsApiRequest)request).send();
			 
		}
	}

	@Test 
    void getRouteSetsTravelModeToWalking() throws ApiException, InterruptedException, IOException, RouteException, TypeException {
		StoringDirectionsApiRequest request = new StoringDirectionsApiRequest();
		RouteGetterWithStoringDirectionsApi generator = new RouteGetterWithStoringDirectionsApi(request);
		generator.getRoute(DEFAULT_LATLNG, setupWayPoints());
		assertEquals(TravelMode.WALKING, request.travelMode);
	}
	
	@Test 
    void getRouteSetsRestrictionOnFerries() throws ApiException, InterruptedException, IOException, RouteException, TypeException {
		StoringDirectionsApiRequest request = new StoringDirectionsApiRequest();
		RouteGetterWithStoringDirectionsApi generator = new RouteGetterWithStoringDirectionsApi(request);
		generator.getRoute(DEFAULT_LATLNG, setupWayPoints());
		assertTrue(Arrays.asList(request.restrictions).contains(RouteRestriction.FERRIES));
	}
	
	@Test 
    void getRouteSetsRestrictionOnHighways() throws ApiException, InterruptedException, IOException, RouteException, TypeException {
		StoringDirectionsApiRequest request = new StoringDirectionsApiRequest();
		RouteGetterWithStoringDirectionsApi generator = new RouteGetterWithStoringDirectionsApi(request);
		generator.getRoute(DEFAULT_LATLNG, setupWayPoints());
		assertTrue(Arrays.asList(request.restrictions).contains(RouteRestriction.HIGHWAYS));
	}
	
	@Test 
    void getRouteDoesntOptimizeWaypoints() throws ApiException, InterruptedException, IOException, RouteException, TypeException {
		StoringDirectionsApiRequest request = new StoringDirectionsApiRequest();
		RouteGetterWithStoringDirectionsApi generator = new RouteGetterWithStoringDirectionsApi(request);
		generator.getRoute(DEFAULT_LATLNG, setupWayPoints());
		assertFalse(request.optimizedWayPoints);
	}
	
	@Test 
    void getRouteSendsRequest() throws ApiException, InterruptedException, IOException, RouteException, TypeException {
		StoringDirectionsApiRequest request = new StoringDirectionsApiRequest();
		RouteGetterWithStoringDirectionsApi generator = new RouteGetterWithStoringDirectionsApi(request);
		generator.getRoute(DEFAULT_LATLNG, setupWayPoints());
		assertTrue(request.sent);
	}
	
	@Test 
    void getRouteUsesFirstRouteFromResultToCreateRoute() throws ApiException, InterruptedException, IOException, RouteException, TypeException {
		StoringDirectionsApiRequest request = new StoringDirectionsApiRequest();
		RouteGetterWithStoringDirectionsApi generator = new RouteGetterWithStoringDirectionsApi(request);
		Route route = generator.getRoute(DEFAULT_LATLNG, setupWayPoints());
		assertEquals(request.polyCoordinatesForFirstRoute, route.getPolyCoordinates());
	}
	
	@Test 
    void getRouteUsesSpecifiedStartPointToCreateRoute() throws ApiException, InterruptedException, IOException, RouteException, TypeException {
		StoringDirectionsApiRequest request = new StoringDirectionsApiRequest();
		RouteGetterWithStoringDirectionsApi generator = new RouteGetterWithStoringDirectionsApi(request);
		Route route = generator.getRoute(DEFAULT_LATLNG, setupWayPoints());
		assertEquals(DEFAULT_LATLNG, route.getStartPoint());
	}
	
	@Test 
    void getRouteUsesGeneratedWaypointsToCreateRoute() throws ApiException, InterruptedException, IOException, RouteException, TypeException {
		StoringDirectionsApiRequest request = new StoringDirectionsApiRequest();
		RouteGetterWithStoringDirectionsApi generator = new RouteGetterWithStoringDirectionsApi(request);
		Route route = generator.getRoute(DEFAULT_LATLNG, setupWayPoints());
		assertEquals(setupWayPoints(), route.getWaypoints());
	}

	@Test 
    void getRouteSetsSpecifiedStartPointAsDestination() throws ApiException, InterruptedException, IOException, RouteException {
		StoringDirectionsApiRequest request = new StoringDirectionsApiRequest();
		RouteGetterWithStoringDirectionsApi generator = new RouteGetterWithStoringDirectionsApi(request);
		generator.getRoute(DEFAULT_LATLNG, setupWayPoints());
		assertEquals(DEFAULT_LATLNG, request.destination);
	}
	
	@Test 
    void getRouteSetsSpecifiedStartPointAsStartPoint() throws ApiException, InterruptedException, IOException, RouteException {
		StoringDirectionsApiRequest request = new StoringDirectionsApiRequest();
		RouteGetterWithStoringDirectionsApi  generator = new RouteGetterWithStoringDirectionsApi (request);
		generator.getRoute(DEFAULT_LATLNG, setupWayPoints());
		assertEquals(DEFAULT_LATLNG, request.startPoint);
	}
}
