package group75.walkInProgress.route;

import java.io.IOException;
import java.util.List;

import com.google.maps.DirectionsApi;
import com.google.maps.DirectionsApiRequest;
import com.google.maps.DirectionsApi.RouteRestriction;
import com.google.maps.errors.ApiException;
import com.google.maps.model.DirectionsResult;
import com.google.maps.model.LatLng;
import com.google.maps.model.TravelMode;

public class RouteGetter {
	
	DirectionsApiRequest getDirectionsRequest() {
		return DirectionsApi.newRequest(MapsContext.getInstance());
	}
	
	DirectionsResult sendDirectionsRequest(DirectionsApiRequest request) throws ApiException, InterruptedException, IOException {
		return request.await();
	}

	public Route getRoute(LatLng startPoint, List<LatLng> waypoints) throws ApiException, InterruptedException, IOException, RouteException {
		DirectionsApiRequest request = getDirectionsRequest();
		request.origin(startPoint)
			.destination(startPoint)
			.waypoints(waypoints.toArray(new LatLng[waypoints.size()]))
			.mode(TravelMode.WALKING)
			.avoid(RouteRestriction.FERRIES, RouteRestriction.HIGHWAYS)
			.optimizeWaypoints(false);
		DirectionsResult result = sendDirectionsRequest(request);
		return new Route(result.routes[0], waypoints, startPoint);
	}

}
