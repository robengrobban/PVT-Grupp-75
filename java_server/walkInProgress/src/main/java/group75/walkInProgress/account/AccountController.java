package group75.walkInProgress.account;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

@Controller
@RequestMapping(path="/account")
public class AccountController {

    @GetMapping(path="/create")
    public ResponseEntity<String> getCircularRoute(@RequestParam String id) {

        return new ResponseEntity<String>(id, HttpStatus.OK);

    }

}