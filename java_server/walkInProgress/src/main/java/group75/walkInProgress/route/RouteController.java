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
import com.google.maps.model.PlaceType;

@Controller
@RequestMapping(path="/route")
public class RouteController {
	

	  @Autowired 
	  private RouteRepository routeRepository;
	  @Autowired 
	  private IRouteService service;
	
	  @PostMapping(path="/save", consumes = "application/json", produces = "application/json")
	  public @ResponseBody Route saveRoute(@RequestBody Route route) {
		  return routeRepository.save(route);
	  }
	
	  @GetMapping(path="/generate")
	  public ResponseEntity<Route> getCircularRoute(@RequestParam double lat, double lng, int duration, double radians, Optional<String> type) {
		  Route route = null;
		  
			try {
				if(type.isPresent()) {
					route = service.getRoute(new LatLng(lat, lng), duration, radians, type.get().toUpperCase());
				 } else {
					route = service.getRoute(new LatLng(lat, lng), duration, radians);
				 }
			} catch(RouteException | ZeroResultsException e){
				e.printStackTrace();
				return new ResponseEntity<Route>(HttpStatus.NOT_FOUND);
			} catch (InvalidRequestException | TypeException e) {
				e.printStackTrace();
				return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
			} catch (ApiException | InterruptedException | IOException e) {
				e.printStackTrace();
				return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
			}
		  if(route != null) {
			  return new ResponseEntity<Route>(route, HttpStatus.OK);
		  } else {
			  return new ResponseEntity<Route>(HttpStatus.NOT_FOUND);
		  }
	  }

}
