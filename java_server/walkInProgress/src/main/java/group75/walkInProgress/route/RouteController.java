package group75.walkInProgress.route;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import com.google.maps.model.LatLng;

@Controller
@RequestMapping(path="/route")
public class RouteController {
	private final RouteService service = new RouteService();
	  @Autowired 
	  private RouteRepository routeRepository;
	
	  @PostMapping(path="/save", consumes = "application/json", produces = "application/json")
	  public @ResponseBody Route saveRoute(@RequestBody Route route) {
		  System.out.print(route);
		  return routeRepository.save(route);
	  }
	
	  @GetMapping(path="/generate")
	  public ResponseEntity<Route> getCircularRoute(@RequestParam double lat, double lng, int duration, double radians) {
		  Route route = service.getRoute(new LatLng(lat, lng), duration, radians);
		  if(route != null) {
			  return new ResponseEntity<Route>(route, HttpStatus.OK);
		  } else {
			  return new ResponseEntity<Route>(HttpStatus.NOT_FOUND);
		  }
	     
	  }

}
