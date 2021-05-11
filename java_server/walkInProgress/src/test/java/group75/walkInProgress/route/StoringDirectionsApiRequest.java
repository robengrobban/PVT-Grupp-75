package group75.walkInProgress.route;

import com.google.maps.DirectionsApiRequest;

import java.util.ArrayList;
import java.util.List;

import com.google.maps.DirectionsApi.RouteRestriction;
import com.google.maps.model.Bounds;
import com.google.maps.model.DirectionsLeg;
import com.google.maps.model.DirectionsResult;
import com.google.maps.model.DirectionsRoute;
import com.google.maps.model.DirectionsStep;
import com.google.maps.model.Duration;
import com.google.maps.model.EncodedPolyline;
import com.google.maps.model.Distance;
import com.google.maps.model.LatLng;
import com.google.maps.model.TravelMode;

class StoringDirectionsApiRequest extends DirectionsApiRequest {
	LatLng startPoint;
	LatLng destination;
	LatLng waypoints[];
	List<LatLng> polyCoordinatesForFirstRoute;
	TravelMode travelMode;
	RouteRestriction restrictions[];
	boolean optimizedWayPoints;
	boolean sent;

	public StoringDirectionsApiRequest() {
		super(null);
		polyCoordinatesForFirstRoute = new ArrayList<>();
		polyCoordinatesForFirstRoute.add(new LatLng(10.0,40.5));
	}
	
	@Override
	public StoringDirectionsApiRequest origin(LatLng startPoint) {
		this.startPoint = startPoint;
		return this;
	}
	
	@Override
	public StoringDirectionsApiRequest destination(LatLng destination) {
		this.destination = destination;
		return this;
	}
	
	@Override
	public StoringDirectionsApiRequest waypoints(LatLng... waypoints) {
		this.waypoints = waypoints;
		return this;
	}
	
	@Override
	public StoringDirectionsApiRequest mode(TravelMode travelMode) {
		this.travelMode = travelMode;
		return this;
	}
	
	@Override
	public StoringDirectionsApiRequest avoid(RouteRestriction... restrictions) {
		this.restrictions = restrictions;
		return this;
	}
	
	@Override
	public StoringDirectionsApiRequest optimizeWaypoints(boolean optimize) {
		this.optimizedWayPoints = optimize;
		return this;
	}
	
	DirectionsResult send() {
		sent = true;
		DirectionsResult result = new DirectionsResult();
		DirectionsRoute route = new DirectionsRoute();
		Bounds bounds = new Bounds();
		bounds.northeast = new LatLng(0,0);
		bounds.southwest = new LatLng(0,0);
		route.bounds = bounds;
		DirectionsLeg leg = new DirectionsLeg();
		DirectionsStep step = new DirectionsStep();
		step.distance = new Distance();
		step.duration = new Duration();
		step.htmlInstructions = "";
		EncodedPolyline polyline = new EncodedPolyline(polyCoordinatesForFirstRoute);
		step.polyline = polyline;
		DirectionsStep steps[] = {step};
		leg.steps = steps;
		DirectionsLeg legs[] = {leg};
		route.legs = legs;
		DirectionsRoute routes[] = {route, new DirectionsRoute()};
		result.routes = routes;

			

		return result;
	}
}
