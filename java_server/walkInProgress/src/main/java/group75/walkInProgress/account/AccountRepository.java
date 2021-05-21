package group75.walkInProgress.account;

import org.springframework.data.repository.CrudRepository;

import java.util.List;

public interface AccountRepository extends CrudRepository<Account, Integer> {

	List<Account> findAccountByEmail(String email);
	boolean existsAccountByEmail(String email);

}