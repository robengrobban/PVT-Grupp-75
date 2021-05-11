package group75.walkInProgress.account;

import org.springframework.data.repository.CrudRepository;

public interface AccountRepository extends CrudRepository<Account, Integer> {

	boolean existsAccountByEmail(String email);

}