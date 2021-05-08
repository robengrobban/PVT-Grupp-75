package group75.walkInProgress.route;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;

import com.google.maps.model.LatLng;

class RouteServiceTest {
	private static final double DEFAULT_LATITUDE = 58.21;
	private static final double DEFAULT_LONGITUDE = 17.34;
	private static final double DEFAULT_LATITUDE_CHANGE = 10;
	private static final double DEFAULT_LONGITUDE_CHANGE = 5;
	private static final RouteService service = new RouteService();

	@Test
	void getBearingReturnsHalfPIWhenOnlyLatitudeIncrease() {
		LatLng startpoint = new LatLng(DEFAULT_LATITUDE, DEFAULT_LONGITUDE);
		LatLng endPoint = new LatLng(DEFAULT_LATITUDE+DEFAULT_LATITUDE_CHANGE, DEFAULT_LONGITUDE);
		assertEquals(Math.PI/2, service.getBearing(startpoint, endPoint), 0.05);
	}
	
	@Test
	void getBearingReturnsOneAndAHalfPIWhenOnlyLatitudeDecrease() {
		LatLng startpoint = new LatLng(DEFAULT_LATITUDE, DEFAULT_LONGITUDE);
		LatLng endPoint = new LatLng(DEFAULT_LATITUDE-DEFAULT_LATITUDE_CHANGE, DEFAULT_LONGITUDE);
		assertEquals(1.5 *Math.PI, service.getBearing(startpoint, endPoint), 0.05);
	}
	
	@Test
	void getBearingReturnsZeroWhenOnlyLongitudeIncrease() {
		LatLng startpoint = new LatLng(DEFAULT_LATITUDE, DEFAULT_LONGITUDE);
		LatLng endPoint = new LatLng(DEFAULT_LATITUDE, DEFAULT_LONGITUDE+DEFAULT_LONGITUDE_CHANGE);
		assertEquals(0, service.getBearing(startpoint, endPoint), 0.05);
	}
	
	@Test
	void getBearingReturnsPIWhenOnlyLongitudeDecrease() {
		LatLng startpoint = new LatLng(DEFAULT_LATITUDE, DEFAULT_LONGITUDE);
		LatLng endPoint = new LatLng(DEFAULT_LATITUDE, DEFAULT_LONGITUDE-DEFAULT_LONGITUDE_CHANGE);
		assertEquals(Math.PI, service.getBearing(startpoint, endPoint), 0.05);
	}

}
