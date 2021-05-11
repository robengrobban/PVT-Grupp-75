package group75.walkInProgress.route;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.io.IOException;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import com.google.maps.errors.ApiException;
import com.google.maps.errors.InvalidRequestException;
import com.google.maps.errors.ZeroResultsException;
import com.google.maps.model.LatLng;

@Controller
@RequestMapping(path = "/route")
public class RouteController {

	@Autowired
	private RouteRepository routeRepository;
	@Autowired
	private IRouteService service;

	@PostMapping(path = "/save", consumes = "application/json", produces = "application/json")
	public @ResponseBody Route saveRoute(@RequestBody Route route) {
		return routeRepository.save(route);
	}

	/**
	 * 	 * Ties to find a circular walking route starting and ending at the
	 * specified Latitude and longitude, with a duration close to the specified duration, 
	 * starting at a bearing close to the specified bearing.
	 * If the type is present and corresponds to the name of one of Google 
	 * PlaceTypes the method tries to find a route passing through a point
	 * with the specified type. If no such points are found within a walk 
	 * of the specified duration the method tries to find a route without 
	 * such a point (same as if no type had been present).
	 * If multiple points of specified type is found within a walk of specified
	 * duration the point with the closest bearing to specified bearing is chosen.
	 * This overrides the specified bearing and sets the bearing for the start of 
	 * the walk to the bearing to the chosen point of specified type.
	 * The point of the specified type, if found, will always be the first point 
	 * of the walk.
	 * Returns bad request if type is not a valid Google PlaceType, duration is null
	 * or given lat and long are not valid. 
	 * Returns not found if a route can't be generated within a reasonable time or if
	 * the specified duration, location and bearing results in a route including a 
	 * ferry.
	 * Returns Internal server error if something unexpected happens or if something 
	 * goes wrong when connecting to Google Maps
	 * 
	 * @param lat a latitude where the route should start and end
	 * @param lng a longitude where the route should start and end
	 * @param duration a positive duration for the walking route (approximate)
	 * @param radians a bearing that the walk should start with 
	 * @param type type a type corresponding to a name for a Google PlaceType, 
	 * 			if present the method tries to find a route passing through a 
	 * 			point of specified type
	 * @return a response entity with route in Json format in the body if found
	 * 
	 */
	@GetMapping(path = "/generate")
	public ResponseEntity<Route> getCircularRoute(@RequestParam double lat, double lng, int duration, double radians,
			Optional<String> type) {
		if (duration < 0) {
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
		Route route = null;

		try {
			route = service.getRoute(new LatLng(lat, lng), duration, radians, type.orElse(null));
		} catch (RouteException | ZeroResultsException e) {
			e.printStackTrace();
			return new ResponseEntity<Route>(HttpStatus.NOT_FOUND);
		} catch (InvalidRequestException | TypeException e) {
			e.printStackTrace();
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		} catch (ApiException | InterruptedException | IOException e) {
			e.printStackTrace();
			return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
		}
		if (route != null) {
			return new ResponseEntity<Route>(route, HttpStatus.OK);
		} else {
			return new ResponseEntity<Route>(HttpStatus.NOT_FOUND);
		}
	}

}
