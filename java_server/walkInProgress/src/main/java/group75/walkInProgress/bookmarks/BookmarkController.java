package group75.walkInProgress.bookmarks;


import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import group75.walkInProgress.Server;



@Controller
@RequestMapping(path = "/bookmarks")
public class BookmarkController {
	
    @Autowired
    private BookmarkRepository bookmarkRepository;
    
    @PostMapping(path="/add",consumes="application/json",produces="application/json")
    public @ResponseBody ResponseEntity<Bookmark> saveBookmark(@RequestBody BookmarkBody bookmarkBody) {
    	if(bookmarkBody==null || bookmarkBody.getRouteInfo() == null || bookmarkBody.getRouteInfo().getStartPoint()== null || bookmarkBody.getRouteInfo().getWaypoints()==null) {
    		return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    	}
        final String target = Server.NAME + "/account/userFromToken?token="+bookmarkBody.getToken();
        final RestTemplate restTemplate = new RestTemplate();
        try {
            UserInfo response = restTemplate.getForObject(target, UserInfo.class);
            int id = response.getId();
            Stream<Bookmark> stream = bookmarkRepository.findByUserId(id).stream();
            List<Bookmark> existing = stream.filter(b -> b.getRouteInfo().equals(bookmarkBody.getRouteInfo())).collect(Collectors.toList());
            if(!existing.isEmpty()) {
            	return new ResponseEntity<>(existing.get(0), HttpStatus.CONFLICT);
            }
            Bookmark bookmark = bookmarkRepository.save(new Bookmark(id, bookmarkBody.getRouteInfo()));
            return new ResponseEntity<>(bookmark, HttpStatus.OK);
        } catch (RestClientException e) {
        	System.out.println(e);
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }
    }
    
    @DeleteMapping(path="/remove")
    public @ResponseBody ResponseEntity<Bookmark> deleteBookmark(@RequestParam String token, @RequestParam int bookmarkId) {
        final String target = Server.NAME + "/account/userFromToken?token="+token;
        final RestTemplate restTemplate = new RestTemplate();
        try {
            UserInfo response = restTemplate.getForObject(target, UserInfo.class);
            int userId = response.getId();
            Optional<Bookmark> bookmark = bookmarkRepository.findById(bookmarkId);
            if(bookmark.isPresent() && bookmark.get().getUserId() != userId) {
            	return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
            }
            bookmarkRepository.deleteById(bookmarkId);
            return new ResponseEntity<>(HttpStatus.NO_CONTENT);
        } catch (RestClientException e) {
        	System.out.println(e);
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        } catch (EmptyResultDataAccessException e) {
        	return new ResponseEntity<>(HttpStatus.NO_CONTENT);
        }
    }
    
    @GetMapping(path="")
    public @ResponseBody ResponseEntity<Iterable<Bookmark>> getAllBookmarks(@RequestParam String token) {
        final String target = Server.NAME + "/account/userFromToken?token="+token;
        final RestTemplate restTemplate = new RestTemplate();
        try {
            UserInfo response = restTemplate.getForObject(target, UserInfo.class);
            int id = response.getId();
            return new ResponseEntity<>(bookmarkRepository.findByUserId(id), HttpStatus.OK);
        } catch (RestClientException e) {
        	System.out.println(e);
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }
    }

}
