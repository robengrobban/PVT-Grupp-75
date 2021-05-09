package group75.walkInProgress.route;

import com.google.maps.GeoApiContext;

public class MapsContext {
	private static final String apiKey = "AIzaSyD0155XjMU4bkctsOn9e4I6Vgxwz-hKj10";
	private static GeoApiContext context; 
	
	private MapsContext() {}
	
	static GeoApiContext getInstance() {
		if (context == null) {
			context = new GeoApiContext.Builder()
		            .apiKey(apiKey)
		            .build();
		}
		return context;
	}

}
