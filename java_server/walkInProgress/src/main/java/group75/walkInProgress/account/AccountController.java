package group75.walkInProgress.account;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.util.List;

@RestController
@RequestMapping(path="/account")
public class AccountController {

    @Autowired
    private AccountRepository accountRepository;

    @PostMapping(path="/create",consumes="application/json",produces="application/json")
    public @ResponseBody ResponseEntity<Account> saveAccount(@RequestBody Account account) {

        final String target = "https://group5-75.pvt.dsv.su.se/account/token?token="+account.getToken();
        final RestTemplate restTemplate = new RestTemplate();
        try {
            Boolean response = restTemplate.getForObject(target, Boolean.class);
            if ( !response ) {
                return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
            }
        } catch (RestClientException e) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }

        // TODO: Update to use service "/exists"
        String email = account.getEmail();
        boolean exists = accountRepository.existsAccountByEmail(email);

        if ( exists ) {
            // TODO: Update to use service "/lookup"
            account = accountRepository.findAccountByEmail(email).get(0);
            return new ResponseEntity<>(account, HttpStatus.CONFLICT);
        }

        account = new Account();
        account.setEmail(email);
        accountRepository.save(account);

        return new ResponseEntity<>(account, HttpStatus.OK);
    }

    @GetMapping(path="/token")
    public @ResponseBody ResponseEntity<Boolean> validToken(String token) {
        final String target = "https://oauth2.googleapis.com/tokeninfo?access_token="+token;
        final RestTemplate restTemplate = new RestTemplate();
        try {
            GoogleToken response = restTemplate.getForObject(target, GoogleToken.class);
            System.out.println(response);
            int expires = Integer.parseInt(response.expires_in);
            if ( expires <= 0 ) {
                return new ResponseEntity<>(false, HttpStatus.OK);
            }
            return new ResponseEntity<>(true, HttpStatus.OK);
        } catch (RestClientException e) {
            return new ResponseEntity<>(false, HttpStatus.OK);
        }
    }
    
    @GetMapping(path="/userFromToken")
    public @ResponseBody ResponseEntity<Account> userFromToken(@RequestParam String token) {
        final String target = "https://oauth2.googleapis.com/tokeninfo?access_token="+token;
        final RestTemplate restTemplate = new RestTemplate();
        try {
            GoogleToken response = restTemplate.getForObject(target, GoogleToken.class);
            int expires = Integer.parseInt(response.expires_in);
            if ( expires <= 0 ) {
                return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
            }
            //Hopefully I understand this correctly
            if(!response.aud.equals("1097591538869-bbhopqak3kh5b7d6ceqbm9ieef9l1vdl.apps.googleusercontent.com")) {
            	return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
            }
            List<Account> account = accountRepository.findAccountByEmail(response.email);
            if ( account == null || account.isEmpty() ) {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
            return new ResponseEntity<>(account.get(0), HttpStatus.OK);
        } catch (RestClientException e) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }
    }

    @GetMapping(path="/lookup")
    public @ResponseBody ResponseEntity<Account> findAccountByEmail(String email, String token) {
        final String target = "https://group5-75.pvt.dsv.su.se/account/token?token="+token;
        final RestTemplate restTemplate = new RestTemplate();
        try {
            Boolean response = restTemplate.getForObject(target, Boolean.class);
            if ( !response ) {
                return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
            }
        } catch (RestClientException e) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }

        List<Account> account = accountRepository.findAccountByEmail(email);
        if ( account == null || account.isEmpty() ) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
        return new ResponseEntity<>(account.get(0), HttpStatus.OK);
    }
    
    @GetMapping(path="/all")
    public @ResponseBody ResponseEntity<Iterable<Account>> getAllAccounts(@RequestParam String token) {
        final String target = "https://group5-75.pvt.dsv.su.se/account/token?token="+token;
        final RestTemplate restTemplate = new RestTemplate();
        try {
            Boolean response = restTemplate.getForObject(target, Boolean.class);
            if ( !response ) {
                return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
            }
        } catch (RestClientException e) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }

        return new ResponseEntity<>(accountRepository.findAll(), HttpStatus.OK);
    }

    @GetMapping(path="/exists")
    public @ResponseBody ResponseEntity<Boolean> existsAccount(@RequestParam String email, String token) {
        final String target = "https://group5-75.pvt.dsv.su.se/account/token?token="+token;
        final RestTemplate restTemplate = new RestTemplate();
        try {
            Boolean response = restTemplate.getForObject(target, Boolean.class);
            if ( !response ) {
                return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
            }
        } catch (RestClientException e) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }

        return new ResponseEntity<>(accountRepository.existsAccountByEmail(email), HttpStatus.OK);
    }

}