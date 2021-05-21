package group75.walkInProgress.account;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

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

    @GetMapping(path="/lookup")
    public @ResponseBody ResponseEntity<Account> findAccountByEmail(String email) {
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