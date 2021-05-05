package group75.walkInProgress.route;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.google.maps.PlacesApi;
import com.google.maps.errors.ApiException;
import com.google.maps.model.LatLng;
import com.google.maps.model.PlaceType;

public class NearbyService {
	
	List<LatLng> getPlacesNearby(LatLng startpoint, int distanceInMeters, String type) {
		var request = PlacesApi.nearbySearchQuery(MapsContext.getInstance(), startpoint);
		List<LatLng> places = new ArrayList<>();
		request.type(PlaceType.valueOf(type));
		request.radius(distanceInMeters);
		try {
			var result = request.await();
			for(var res : result.results) {
				places.add(new LatLng(res.geometry.location.lat, res.geometry.location.lng));
				System.out.println(res.geometry.location.lat + ", " + res.geometry.location.lng);
			}
			return places;
		} catch (ApiException | InterruptedException | IOException e) {
			e.printStackTrace();
			return null;
		}
	}
	
}
