package group75.walkInProgress.account;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

@RestController
@RequestMapping(path="/account")
public class AccountController {

    @Autowired
    private AccountRepository accountRepository;

    @PostMapping(path="/create",consumes="application/json",produces="application/json")
    public @ResponseBody ResponseEntity<Account> saveAccount(@RequestBody Account account) {

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
        RestTemplate restTemplate = new RestTemplate();
        try {
            GoogleToken response = restTemplate.getForObject(target, GoogleToken.class);
            int expires = Integer.parseInt(response.expires_in);
            if ( expires <= 0 ) {
                return new ResponseEntity<>(false, HttpStatus.OK);
            }
            return new ResponseEntity<>(true, HttpStatus.OK);
        } catch (RestClientException e) {
            return new ResponseEntity<>(false, HttpStatus.OK);
        }
    }

    @GetMapping(path="/lookup")
    public @ResponseBody ResponseEntity<Account> findAccountByEmail(String email) {
        final String target = "";

        Account account = accountRepository.findAccountByEmail(email).get(0);
        return new ResponseEntity<>(account, HttpStatus.OK);
    }
    
    @GetMapping(path="/all")
    public @ResponseBody Iterable<Account> getAllAccounts() {
        return accountRepository.findAll();
    }

    @GetMapping(path="/exists")
    public @ResponseBody ResponseEntity<Boolean> existsAccount(@RequestParam String email) {
        return new ResponseEntity<>(accountRepository.existsAccountByEmail(email), HttpStatus.OK);
    }

}