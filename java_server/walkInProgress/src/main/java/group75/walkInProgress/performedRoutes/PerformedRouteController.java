package group75.walkInProgress.performedRoutes;

import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import group75.walkInProgress.Server;

@Controller
@RequestMapping(path = "/performedRoutes")
public class PerformedRouteController {
	
	
	 @Autowired
	  private PerformedRouteRepository performedRouteRepository;
	 @Autowired
	 private StreakService streakService;
	 
	 @GetMapping(path="/streaks")
	    public @ResponseBody ResponseEntity<List<Streak>> getStreaks(@RequestParam String token) {
	        final String target = Server.NAME + "/account/userFromToken?token="+token;
	        final RestTemplate restTemplate = new RestTemplate();
	        try {
	            UserInfo response = restTemplate.getForObject(target, UserInfo.class);
	            int id = response.getId();
	            List<PerformedRoute> userRoutes = performedRouteRepository.findByUserIdOrderByTimeFinishedAsc(id);
	            List<Streak> streaks = streakService.getStreaks(userRoutes);
	            return new ResponseEntity<>(streaks, HttpStatus.OK);
	        } catch (RestClientException e) {
	        	System.out.println(e);
	            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
	        }
	    }
	 
	 @GetMapping(path="/streaks/longest")
	    public @ResponseBody ResponseEntity<Streak> getLongestStreak(@RequestParam String token) {
	        final String target = Server.NAME + "/account/userFromToken?token="+token;
	        final RestTemplate restTemplate = new RestTemplate();
	        try {
	            UserInfo response = restTemplate.getForObject(target, UserInfo.class);
	            int id = response.getId();
	            List<PerformedRoute> userRoutes = performedRouteRepository.findByUserIdOrderByTimeFinishedAsc(id);
	            Streak streak = streakService.getLongestStreak(userRoutes);
	            return new ResponseEntity<Streak>(streak, HttpStatus.OK);
	        } catch (RestClientException e) {
	        	System.out.println(e);
	            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
	        }
	    }
	 
	 @GetMapping(path="/streaks/current")
	    public @ResponseBody ResponseEntity<Streak> getCurrentStreak(@RequestParam String token) {
	        final String target = Server.NAME + "/account/userFromToken?token="+token;
	        final RestTemplate restTemplate = new RestTemplate();
	        try {
	            UserInfo response = restTemplate.getForObject(target, UserInfo.class);
	            int id = response.getId();
	            List<PerformedRoute> userRoutes = performedRouteRepository.findByUserIdOrderByTimeFinishedAsc(id);
	            Streak streak = streakService.getCurrentStreak(userRoutes);
	            return new ResponseEntity<Streak>(streak, HttpStatus.OK);
	        } catch (RestClientException e) {
	        	System.out.println(e);
	            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
	        }
	    }
	 
    @GetMapping(path="/longestDistance")
    public @ResponseBody ResponseEntity<PerformedRoute> getLongestDistanceRoute(@RequestParam String token) {
        final String target = Server.NAME + "/account/userFromToken?token="+token;
        final RestTemplate restTemplate = new RestTemplate();
        try {
            UserInfo response = restTemplate.getForObject(target, UserInfo.class);
            int id = response.getId();
            return new ResponseEntity<PerformedRoute>(performedRouteRepository.findTopByUserIdOrderByDistanceDesc(id), HttpStatus.OK);
        } catch (RestClientException e) {
        	System.out.println(e);
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }
    }
    
    @GetMapping(path="/totalTime")
    public @ResponseBody ResponseEntity<Integer> getTotalTimeForRoutes(@RequestParam String token) {
        final String target = Server.NAME + "/account/userFromToken?token="+token;
        final RestTemplate restTemplate = new RestTemplate();
        try {
            UserInfo response = restTemplate.getForObject(target, UserInfo.class);
            int id = response.getId();
            Integer total = performedRouteRepository.findTotalTimeByUserId(id);
            return new ResponseEntity<Integer>(total==null ? 0 : total, HttpStatus.OK);
        } catch (RestClientException e) {
        	System.out.println(e);
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }
    }
    
    @GetMapping(path="/totalDistance")
    public @ResponseBody ResponseEntity<Integer> getTotalDistanceForRoutes(@RequestParam String token) {
        final String target = Server.NAME + "/account/userFromToken?token="+token;
        final RestTemplate restTemplate = new RestTemplate();
        try {
            UserInfo response = restTemplate.getForObject(target, UserInfo.class);
            int id = response.getId();
            Integer total = performedRouteRepository.findTotalDistanceByUserId(id);
            return new ResponseEntity<Integer>(total==null ? 0 : total, HttpStatus.OK);
        } catch (RestClientException e) {
        	System.out.println(e);
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }
    }
    
    @GetMapping(path="/longestDuration")
    public @ResponseBody ResponseEntity<PerformedRoute> getLongestDurationRoute(@RequestParam String token) {
        final String target = Server.NAME + "/account/userFromToken?token="+token;
        final RestTemplate restTemplate = new RestTemplate();
        try {
            UserInfo response = restTemplate.getForObject(target, UserInfo.class);
            int id = response.getId();
            return new ResponseEntity<PerformedRoute>(performedRouteRepository.findTopByUserIdOrderByActualDurationDesc(id), HttpStatus.OK);
        } catch (RestClientException e) {
        	System.out.println(e);
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }
    }
    
    @PostMapping(path="/add",consumes="application/json",produces="application/json")
    public @ResponseBody ResponseEntity<PerformedRoute> saveRoute(@RequestBody PerformedRouteBody performedRouteBody) {
    	
    	PerformedRoute performedRoute = performedRouteBody.getPerformedRoute();
    	if(performedRouteBody==null || performedRoute == null || performedRoute.getStartPoint()== null || performedRoute.getWaypoints()==null || performedRoute.getTimeFinished() == null) {
    		return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    	}
        final String target = Server.NAME + "/account/userFromToken?token="+performedRouteBody.getToken();
        final RestTemplate restTemplate = new RestTemplate();
        try {
            UserInfo response = restTemplate.getForObject(target, UserInfo.class);
            int id = response.getId();
            performedRoute.setUserId(id);
            Stream<PerformedRoute> stream = performedRouteRepository.findByUserId(id).stream();
            List<PerformedRoute> existing = stream.filter(b -> b.equals(performedRoute)).collect(Collectors.toList());
            
            if(!existing.isEmpty()) {
            	return new ResponseEntity<>(existing.get(0), HttpStatus.CONFLICT);
            }

            return new ResponseEntity<>(performedRouteRepository.save(performedRoute), HttpStatus.OK);
        } catch (RestClientException e) {
        	System.out.println(e);
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }
    }
    
    @GetMapping(path="")
    public @ResponseBody ResponseEntity<Iterable<PerformedRoute>> getAllPerformedRoutes(@RequestParam String token) {
        final String target = Server.NAME + "/account/userFromToken?token="+token;
        final RestTemplate restTemplate = new RestTemplate();
        try {
            UserInfo response = restTemplate.getForObject(target, UserInfo.class);
            int id = response.getId();
            return new ResponseEntity<>(performedRouteRepository.findByUserIdOrderByTimeFinishedDesc(id), HttpStatus.OK);
        } catch (RestClientException e) {
        	System.out.println(e);
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }
    }

}
