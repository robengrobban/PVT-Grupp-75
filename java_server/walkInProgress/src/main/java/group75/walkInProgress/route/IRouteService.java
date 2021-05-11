package group75.walkInProgress.route;

import java.io.IOException;

import com.google.maps.errors.ApiException;
import com.google.maps.model.LatLng;

public interface IRouteService {

	
	/**
	 * Ties to find a circular walking route starting and ending at the
	 * specified startPoint, with a duration close to the specified duration, 
	 * starting at a bearing close to the specified bearing.
	 * If no route is found within a reasonable time the method returns null.
	 * If the bearing and duration results in a walk that includes a ferry an 
	 * exception is thrown.
	 * If the type is not null and corresponds to the name of one of Google 
	 * PlaceTypes the method tries to find a route passing through a point
	 * with the specified type. If no such points are found within a walk 
	 * of the specified duration the method tries to find a route without 
	 * such a point (same as if null had been passed in as type).
	 * If multiple points of specified type is found within a walk of specified
	 * duration the point with the closest bearing to specified bearing is chosen.
	 * This overrides the specified bearing and sets the bearing for the start of 
	 * the walk to the bearing to the chosen point of specified type.
	 * The point of the specified type, if found, will always be the first point 
	 * of the walk.
	 * @param startPoint a point from where the walk should start and end
	 * @param durationInMinutes a duration in minutes that the method should try to find
	 * @param radians a bearing that the walk should start with in radians,
	 * 			also accepts negative radians and radians larger than tao (2*pi)
	 * @param type a type corresponding to a name for a Google PlaceType, if not
	 * 			null the method tries to find a route passing through a point of
	 * 			specified type
	 * @return the route generated if found, null if no route is found
	 * @throws ApiException if connection to Google API fails
	 * @throws InterruptedException if connection to Google API fails
	 * @throws IOException if connection to Google API fails
	 * @throws RouteException if the produced walking route includes taking a ferry
	 * @throws TypeException if the supplied type is not supported 
	 */
	Route getRoute(LatLng startPoint, double durationInMinutes, double radians, String type)
			throws ApiException, InterruptedException, IOException, RouteException, TypeException;

}