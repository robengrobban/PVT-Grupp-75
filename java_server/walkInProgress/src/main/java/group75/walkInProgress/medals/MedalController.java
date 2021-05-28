package group75.walkInProgress.medals;

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

import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import group75.walkInProgress.Server;



@Controller
@RequestMapping(path = "/medals")
public class MedalController {
	
	@Autowired
	  private MedalRepository medalRepository;
	
	
    @PostMapping(path="/add",consumes="application/json",produces="application/json")
    public @ResponseBody ResponseEntity<Medal> saveMedal(@RequestBody MedalBody medalBody) {
    	Medal medal = medalBody.getMedal();
    	if(medalBody==null || medal == null || medal.getType()== null || medal.getTimeEarned() == null) {
    		return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    	}
        final String target = Server.NAME + "/account/userFromToken?token="+medalBody.getToken();
        final RestTemplate restTemplate = new RestTemplate();
        try {
            UserInfo response = restTemplate.getForObject(target, UserInfo.class);
            int id = response.getId();
            medal.setUserId(id);
            Stream<Medal> stream = medalRepository.findByUserId(id).stream();
            List<Medal> existing = stream.filter(b -> b.equals(medal)).collect(Collectors.toList());
            
            if(!existing.isEmpty()) {
            	return new ResponseEntity<>(existing.get(0), HttpStatus.CONFLICT);
            }

            return new ResponseEntity<>(medalRepository.save(medal), HttpStatus.OK);
        } catch (RestClientException e) {
        	System.out.println(e);
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }
    }
	
    @GetMapping(path="")
    public @ResponseBody ResponseEntity<Iterable<Medal>> getAllEarnedMedals(@RequestParam String token) {
        final String target = Server.NAME + "/account/userFromToken?token="+token;
        final RestTemplate restTemplate = new RestTemplate();
        try {
            UserInfo response = restTemplate.getForObject(target, UserInfo.class);
            int id = response.getId();
            return new ResponseEntity<>(medalRepository.findByUserId(id), HttpStatus.OK);
        } catch (RestClientException e) {
        	System.out.println(e);
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }
    }

}
