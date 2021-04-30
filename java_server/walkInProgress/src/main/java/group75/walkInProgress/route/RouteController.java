package group75.walkInProgress.route;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.google.maps.model.LatLng;

@Controller
@RequestMapping
public class RouteController {
	private final RouteService service = new RouteService();
	
	  @GetMapping(path="/all")
	  public @ResponseBody Route getAllUsers() {
	    return service.getRoute(new LatLng(59.3380733384178, 18.061664496740775), 1);
	  }

}
