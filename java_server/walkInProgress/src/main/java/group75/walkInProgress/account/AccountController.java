package group75.walkInProgress.account;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.List;

@RestController
@RequestMapping(path="/account")
public class AccountController {

    @Autowired
    private AccountRepository accountRepository;

    @PostMapping(path="/create",consumes="application/json",produces="application/json")
    public @ResponseBody ResponseEntity<Account> saveAccount(@RequestBody Account account) {

        // TODO: Update to use service "/exists"
        /*boolean exists = accountRepository.existsAccountByEmail(email);

        if ( exists ) {
            return new ResponseEntity<>(HttpStatus.CONFLICT);
        }

        Account account = new Account();
        account.setEmail(email);
        accountRepository.save(account);

        return new ResponseEntity<>(account, HttpStatus.OK);*/
        return new ResponseEntity<>(account, HttpStatus.OK);
    }

    @GetMapping(path="/all")
    public @ResponseBody Iterable<Account> getAllAccounts() {
        return accountRepository.findAll();
    }

    @GetMapping(path="/exists")
    public @ResponseBody ResponseEntity<Boolean> findAccount(@RequestParam String email) {

        return new ResponseEntity<>(accountRepository.existsAccountByEmail(email), HttpStatus.OK);

    }

}