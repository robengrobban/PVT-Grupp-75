package group75.walkInProgress.route;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.google.maps.PlacesApi;
import com.google.maps.errors.ApiException;
import com.google.maps.model.LatLng;
import com.google.maps.model.PlaceType;
import com.google.maps.model.PlacesSearchResponse;

public class NearbyService {
	
	private static final int METERS_PER_KM = 1000;

	List<LatLng> getPlacesNearby(LatLng startpoint, double distanceInKm, String type) throws ApiException, InterruptedException, IOException, TypeException {
		var request = PlacesApi.nearbySearchQuery(MapsContext.getInstance(), startpoint);
		List<LatLng> places = new ArrayList<>();
		try {
			request.type(PlaceType.valueOf(type));
		} catch (IllegalArgumentException e) {
			throw new TypeException(type + " is not a valid type");
		}
		
		request.radius((int)(distanceInKm*METERS_PER_KM));
		PlacesSearchResponse result = request.await();
		for(var res : result.results) {
			places.add(new LatLng(res.geometry.location.lat, res.geometry.location.lng));
			System.out.println(res.geometry.location.lat + ", " + res.geometry.location.lng);
		}

			return places;

	}
	
}
