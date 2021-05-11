package group75.walkInProgress.route;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;

import com.google.maps.GeoApiContext;

class MapsContextTest {

	@Test
	void getInstanceReturnsMapsContextFirstTimeCalled() {
		assertNotNull(MapsContext.getInstance());
		assertTrue(MapsContext.getInstance() instanceof GeoApiContext);
	}
	
	@Test
	void getInstanceReturnsSameInstanceIfCalledTwice() {
		GeoApiContext first = MapsContext.getInstance();
		GeoApiContext second = MapsContext.getInstance();
		assertSame(first, second);
	}


}
