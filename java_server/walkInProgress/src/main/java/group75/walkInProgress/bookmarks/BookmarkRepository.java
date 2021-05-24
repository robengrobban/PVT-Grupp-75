package group75.walkInProgress.bookmarks;

import java.util.List;

import org.springframework.data.repository.CrudRepository;

import com.google.maps.model.LatLng;


public interface BookmarkRepository extends CrudRepository<Bookmark, Integer>{
	

	List<Bookmark> findByUserId(int id);


}

