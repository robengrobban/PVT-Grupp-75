package group75.walkInProgress.route;

import com.google.maps.GeoApiContext;

public class MapsContext {
	private static final String apiKey = "AIzaSyAPpfAqIMC612h4Z0UwGFrIg9K8-IZTq1s";
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
