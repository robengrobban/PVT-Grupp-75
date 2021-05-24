package group75.walkInProgress.bookmarks;

import java.util.List;

import org.springframework.data.repository.CrudRepository;



public interface BookmarkRepository extends CrudRepository<Bookmark, Integer>{
	

	List<Bookmark> findByUserId(int id);


}

