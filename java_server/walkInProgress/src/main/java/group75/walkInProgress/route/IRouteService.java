package group75.walkInProgress.route;

import java.io.IOException;

import com.google.maps.errors.ApiException;
import com.google.maps.model.LatLng;

public interface IRouteService {

	Route getRoute(LatLng startPoint, double durationInMinutes, double radians)
			throws ApiException, InterruptedException, IOException, RouteException;

	Route getRoute(LatLng startPoint, double durationInMinutes, double radians, String type)
			throws ApiException, InterruptedException, IOException, RouteException, TypeException;

}