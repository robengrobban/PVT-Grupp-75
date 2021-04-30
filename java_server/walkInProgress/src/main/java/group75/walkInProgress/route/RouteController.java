package group75.walkInProgress.route;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.google.maps.model.LatLng;

@Controller
@RequestMapping
public class RouteController {
	private final RouteService service = new RouteService();
	
	  @GetMapping(path="/circularRoute")
	  public @ResponseBody Route getCircularRoute(@RequestParam double lat, double lng, int duration, double radians) {
	    return service.getRoute(new LatLng(lat, lng), duration, radians);
	  }

}
