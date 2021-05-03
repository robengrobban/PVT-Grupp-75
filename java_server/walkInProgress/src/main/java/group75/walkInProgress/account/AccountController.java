package group75.walkInProgress.account;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.beans.factory.annotation.Autowired;

@Controller
@RequestMapping(path="/account")
public class AccountController {

    @GetMapping(path="/create")
    public ResponseEntity<String> getCircularRoute(@RequestParam String id) {

        return new ResponseEntity<String>(id, HttpStatus.OK);

    }

}