package group75.walkInProgress.route;

import static org.junit.jupiter.api.Assertions.*;

import java.io.IOException;
import org.junit.jupiter.api.Test;
import com.google.maps.errors.ApiException;
import com.google.maps.model.LatLng;

class RouteServiceTest { 
	
	private static final double DEFAULT_LATITUDE = 58.21;
	private static final double DEFAULT_LONGITUDE = 17.34;
	private static final LatLng DEFAULT_LATLNG = new LatLng(DEFAULT_LATITUDE, DEFAULT_LONGITUDE);

	private static final double DEFAULT_ANGLE_IN_RADIANS = Math.toRadians(170);
	private static final int DEFAULT_DURATION_IN_MINUTES = 40;
	private static final int UNACCEPTABLY_HIGH_DURATION = 500;
	private static final int UNACCEPTABLY_LOW_DURATION = -500;
	private static final String DEFAULT_TYPE_OF_INTEREST = "park";

	private static final int DEFAULT_NEGATIVE_NUMBER = -5;
	
	private static final int SECONDS_PER_MINUTE = 60;
	
	
	
	private static final RouteService service = new RouteService();
	
	private static class RouteServiceWithFakeRouteGenerator extends RouteService{
		RouteGenerator generator;
		
		RouteServiceWithFakeRouteGenerator(RouteGenerator generator) {
			this.generator = generator;
		}
		@Override 
		RouteGenerator getRouteGenerator(LatLng startPoint, double durationInMinutes, double radians, String type) {
			return generator;
		};
		
	}
	
	private static class FakeRouteGenerator extends RouteGenerator{
		int numberOfFakeTries;
		boolean increasedCalled;
		boolean decreasedCalled;
		boolean setTypeHasBeenCalled;
		int durationToSetInReturnedRoute;
		String type;
		
		public FakeRouteGenerator(int durationToSetInReturnedRoute) {
			super(DEFAULT_LATLNG, DEFAULT_DURATION_IN_MINUTES, DEFAULT_ANGLE_IN_RADIANS);
			this.durationToSetInReturnedRoute = durationToSetInReturnedRoute;
		}
		
		@Override
		public Route tryToFindRoute() {
			numberOfFakeTries++;
			Route route = new Route();
			route.setDurationInSeconds(durationToSetInReturnedRoute*SECONDS_PER_MINUTE);
			return route;
		}
		
		@Override
		public void increaseCrowFactor() {
			increasedCalled = true;
		}
		
		@Override
		public void decreaseCrowFactor() {
			decreasedCalled = true;
		}
		
		
		@Override
		public int getNumberOfTries() {
			return numberOfFakeTries;
		}
		
		@Override
		public void setTypeOfInterest(String type) {
			setTypeHasBeenCalled = true;
			this.type  = type;
		}
	}
	
	
	//Get Route
	@Test
	void getRouteDoesNotExceedMaximumNumberOfTries() throws ApiException, InterruptedException, IOException, RouteException, TypeException {
		FakeRouteGenerator fakeGenerator = new FakeRouteGenerator(UNACCEPTABLY_HIGH_DURATION);
		RouteService service = new RouteServiceWithFakeRouteGenerator(fakeGenerator);
		service.getRoute(DEFAULT_LATLNG, DEFAULT_DURATION_IN_MINUTES, DEFAULT_ANGLE_IN_RADIANS, null);
		assertEquals(RouteService.getMaximumNumberOfTries(), fakeGenerator.numberOfFakeTries);
	} 
	
	@Test
	void getRouteReturnsRouteIfRouteIsAcceptedDuration() throws ApiException, InterruptedException, IOException, RouteException, TypeException {
		FakeRouteGenerator fakeGenerator = new FakeRouteGenerator(DEFAULT_DURATION_IN_MINUTES);
		RouteService service = new RouteServiceWithFakeRouteGenerator(fakeGenerator);
		Route route = service.getRoute(DEFAULT_LATLNG, DEFAULT_DURATION_IN_MINUTES, DEFAULT_ANGLE_IN_RADIANS, null);
		assertNotNull(route);
	}
	
	@Test
	void getRouteReturnsNullIfNoRouteFoundInMaxNumberOfTries() throws ApiException, InterruptedException, IOException, RouteException, TypeException {
		FakeRouteGenerator fakeGenerator = new FakeRouteGenerator(UNACCEPTABLY_HIGH_DURATION);
		RouteService service = new RouteServiceWithFakeRouteGenerator(fakeGenerator);
		Route route = service.getRoute(DEFAULT_LATLNG, DEFAULT_DURATION_IN_MINUTES, DEFAULT_ANGLE_IN_RADIANS, null);
		assertNull(route);
	} 
	
	@Test
	void getRouteIncreacesCrowFactorIfGeneratedRouteDurationTooShort() throws ApiException, InterruptedException, IOException, RouteException, TypeException {
		FakeRouteGenerator fakeGenerator = new FakeRouteGenerator(UNACCEPTABLY_LOW_DURATION);
		RouteService service = new RouteServiceWithFakeRouteGenerator(fakeGenerator);
		service.getRoute(DEFAULT_LATLNG, DEFAULT_DURATION_IN_MINUTES, DEFAULT_ANGLE_IN_RADIANS, null);
		assertTrue(fakeGenerator.increasedCalled);
	} 
	
	@Test
	void getRouteDecreasesCrowFactorIfGeneratedRouteDurationTooLong() throws ApiException, InterruptedException, IOException, RouteException, TypeException {
		FakeRouteGenerator fakeGenerator = new FakeRouteGenerator(UNACCEPTABLY_HIGH_DURATION);
		RouteService service = new RouteServiceWithFakeRouteGenerator(fakeGenerator);
		service.getRoute(DEFAULT_LATLNG, DEFAULT_DURATION_IN_MINUTES, DEFAULT_ANGLE_IN_RADIANS, null);
		assertTrue(fakeGenerator.decreasedCalled);
	}
	
	@Test 
	void getRouteSetsTypeOfInterestIfNotNull() throws ApiException, InterruptedException, IOException, RouteException, TypeException {
		FakeRouteGenerator fakeGenerator = new FakeRouteGenerator(DEFAULT_DURATION_IN_MINUTES);
		RouteService service = new RouteServiceWithFakeRouteGenerator(fakeGenerator);
		service.getRoute(DEFAULT_LATLNG, DEFAULT_DURATION_IN_MINUTES, DEFAULT_ANGLE_IN_RADIANS, DEFAULT_TYPE_OF_INTEREST);
		assertTrue(fakeGenerator.setTypeHasBeenCalled);
		assertEquals(DEFAULT_TYPE_OF_INTEREST, fakeGenerator.type);
	}
	
	@Test 
	void getRouteDoesNotSetTypeIfNull() throws ApiException, InterruptedException, IOException, RouteException, TypeException {
		FakeRouteGenerator fakeGenerator = new FakeRouteGenerator(DEFAULT_DURATION_IN_MINUTES);
		RouteService service = new RouteServiceWithFakeRouteGenerator(fakeGenerator);
		service.getRoute(DEFAULT_LATLNG, DEFAULT_DURATION_IN_MINUTES, DEFAULT_ANGLE_IN_RADIANS, null);
		assertFalse(fakeGenerator.setTypeHasBeenCalled);
	}
		
	@Test
	void getRoutThrowsIAEIfStartPointIsNull() {
		assertThrows(IllegalArgumentException.class, ()->{
			service.getRoute(null, DEFAULT_DURATION_IN_MINUTES, DEFAULT_ANGLE_IN_RADIANS, null);
			});
	}
	
	@Test
	void getRoutThrowsIAEIfDurationIsNegative() {
		assertThrows(IllegalArgumentException.class, ()->{
			service.getRoute(DEFAULT_LATLNG, -1, DEFAULT_ANGLE_IN_RADIANS, null);
			});
	}
	

	
	
	//IsWithinAcceptedTime
	
	@Test
	void isWithinAcceptedTimeReturnsTrueIfRouteDurationIsExactlySpecifiedDuration() {
		Route route = new Route();
		route.setDurationInSeconds(DEFAULT_DURATION_IN_MINUTES*SECONDS_PER_MINUTE);
		assertTrue(service.isWithinAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
	}
	
	@Test
	void isWithinAcceptedTimeReturnsTrueIfRouteDurationIsLessThanSpecifiedButWithinAcceptedMargin() {
		Route route = new Route();
		int routeDurationToTest = DEFAULT_DURATION_IN_MINUTES-RouteService.getAcceptableDurationDifferenceInMinutes()/2;
		route.setDurationInSeconds(routeDurationToTest*SECONDS_PER_MINUTE);
		assertTrue(service.isWithinAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
	}
	
	@Test
	void isWithinAcceptedTimeReturnsTrueIfRouteDurationIsLargerThanSpecifiedButWithinAcceptedMargin() {
		Route route = new Route();
		int routeDurationToTest = DEFAULT_DURATION_IN_MINUTES+RouteService.getAcceptableDurationDifferenceInMinutes()/2;
		route.setDurationInSeconds(routeDurationToTest*SECONDS_PER_MINUTE);
		assertTrue(service.isWithinAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
	}
	@Test
	void isWithinAcceptedTimeReturnsTrueIfRouteDurationIsExactlyMinimalAcceptedDuration() {
		Route route = new Route();
		int routeDurationToTest = DEFAULT_DURATION_IN_MINUTES-RouteService.getAcceptableDurationDifferenceInMinutes();
		route.setDurationInSeconds(routeDurationToTest*SECONDS_PER_MINUTE);
		assertTrue(service.isWithinAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
	}
	
	@Test
	void isWithinAcceptedTimeReturnsTrueIfRouteDurationIsExactlyMaximalAcceptedDuration() {
		Route route = new Route();
		int routeDurationToTest = DEFAULT_DURATION_IN_MINUTES+RouteService.getAcceptableDurationDifferenceInMinutes();
		route.setDurationInSeconds(routeDurationToTest*SECONDS_PER_MINUTE);
		assertTrue(service.isWithinAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
	}
	
	@Test
	void isWithinAcceptedTimeReturnsFalseIfRouteDurationIsLargerThanAcceptedRange() {
		Route route = new Route();
		int routeDurationToTest = DEFAULT_DURATION_IN_MINUTES+RouteService.getAcceptableDurationDifferenceInMinutes()+1;
		route.setDurationInSeconds(routeDurationToTest*SECONDS_PER_MINUTE);
		assertFalse(service.isWithinAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
	}
	
	@Test
	void isWithinAcceptedTimeReturnsFalseIfRouteDurationIsSmallerThanAcceptedRange() {
		Route route = new Route();
		int routeDurationToTest = DEFAULT_DURATION_IN_MINUTES-RouteService.getAcceptableDurationDifferenceInMinutes()-1;
		route.setDurationInSeconds(routeDurationToTest*SECONDS_PER_MINUTE);
		assertFalse(service.isWithinAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
	}
	
	@Test
	void isWithinAcceptedTimeThrowsIAEIfDurationIsLessThanZero() {
		assertThrows(IllegalArgumentException.class, ()->{service.isWithinAcceptedTime(new Route(), DEFAULT_NEGATIVE_NUMBER);});
	}
	
	@Test
	void isWithinAcceptedTimeThrowsIAEIfRouteIsNull() {
		assertThrows(IllegalArgumentException.class, ()->{service.isWithinAcceptedTime(null, DEFAULT_DURATION_IN_MINUTES);});
	}
	
	//IsUnderAcceptedTime
	
		@Test
		void isUnderAcceptedTimeReturnsFalseIfRouteDurationIsExactlySpecifiedDuration() {
			Route route = new Route();
			route.setDurationInSeconds(DEFAULT_DURATION_IN_MINUTES*SECONDS_PER_MINUTE);
			assertFalse(service.isUnderAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
		}
		
		@Test
		void isWithinAcceptedTimeReturnsFalseIfRouteDurationIsLessThanSpecifiedButWithinAcceptedMargin() {
			Route route = new Route();
			int routeDurationToTest = DEFAULT_DURATION_IN_MINUTES-RouteService.getAcceptableDurationDifferenceInMinutes()/2;
			route.setDurationInSeconds(routeDurationToTest*SECONDS_PER_MINUTE);
			assertFalse(service.isUnderAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
		}

		@Test
		void isUnderAcceptedTimeReturnsFalseIfRouteDurationIsExactlyMinimalAcceptedDuration() {
			Route route = new Route();
			int routeDurationToTest = DEFAULT_DURATION_IN_MINUTES-RouteService.getAcceptableDurationDifferenceInMinutes();
			route.setDurationInSeconds(routeDurationToTest*SECONDS_PER_MINUTE);
			assertFalse(service.isUnderAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
		}
		
		@Test
		void isUnderAcceptedTimeReturnsFalseIfRouteDurationIsLargerThanAcceptedRange() {
			Route route = new Route(); 
			int routeDurationToTest = DEFAULT_DURATION_IN_MINUTES+RouteService.getAcceptableDurationDifferenceInMinutes()+1;
			route.setDurationInSeconds(routeDurationToTest*SECONDS_PER_MINUTE);
			assertFalse(service.isUnderAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
		}
		
		@Test
		void isUnderAcceptedTimeReturnsTrueIfRouteDurationIsSmallerThanAcceptedRange() {
			Route route = new Route();
			int routeDurationToTest = DEFAULT_DURATION_IN_MINUTES-RouteService.getAcceptableDurationDifferenceInMinutes()-1;
			route.setDurationInSeconds(routeDurationToTest*SECONDS_PER_MINUTE);
			assertTrue(service.isUnderAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
		}
		
		@Test
		void isUnderAcceptedTimeThrowsIAEIfDurationIsLessThanZero() {
			assertThrows(IllegalArgumentException.class, ()->{service.isUnderAcceptedTime(new Route(), DEFAULT_NEGATIVE_NUMBER);});
		}
		
		@Test
		void isUnderAcceptedTimeThrowsIAEIfRouteIsNull() {
			assertThrows(IllegalArgumentException.class, ()->{service.isUnderAcceptedTime(null, DEFAULT_DURATION_IN_MINUTES);});
		}
		
		//IsOverAcceptedTime
		
		@Test
		void isOverAcceptedTimeReturnsFalseIfRouteDurationIsExactlySpecifiedDuration() {
			Route route = new Route();
			route.setDurationInSeconds(DEFAULT_DURATION_IN_MINUTES*SECONDS_PER_MINUTE);
			assertFalse(service.isOverAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
		}
		
		@Test
		void isOverAcceptedTimeReturnsFalseIfRouteDurationIsLargerThanSpecifiedButWithinAcceptedMargin() {
			Route route = new Route();
			int routeDurationToTest = DEFAULT_DURATION_IN_MINUTES+RouteService.getAcceptableDurationDifferenceInMinutes()/2;
			route.setDurationInSeconds(routeDurationToTest*SECONDS_PER_MINUTE);
			assertFalse(service.isOverAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
		}

		@Test
		void isOverAcceptedTimeReturnsFalseIfRouteDurationIsExactlyMaximalAcceptedDuration() {
			Route route = new Route();
			int routeDurationToTest = DEFAULT_DURATION_IN_MINUTES+RouteService.getAcceptableDurationDifferenceInMinutes();
			route.setDurationInSeconds(routeDurationToTest*SECONDS_PER_MINUTE);
			assertFalse(service.isOverAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
		}
		
		@Test
		void isOverAcceptedTimeReturnsFalseIfRouteDurationIsSmallerThanAcceptedRange() {
			Route route = new Route();
			int routeDurationToTest = DEFAULT_DURATION_IN_MINUTES-RouteService.getAcceptableDurationDifferenceInMinutes()-1;
			route.setDurationInSeconds(routeDurationToTest*SECONDS_PER_MINUTE);
			assertFalse(service.isOverAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
		}
		
		@Test
		void isOverAcceptedTimeReturnsTrueIfRouteDurationIsLargerThanAcceptedRange() {
			Route route = new Route();
			int routeDurationToTest = DEFAULT_DURATION_IN_MINUTES+RouteService.getAcceptableDurationDifferenceInMinutes()+1;
			route.setDurationInSeconds(routeDurationToTest*SECONDS_PER_MINUTE);
			assertTrue(service.isOverAcceptedTime(route, DEFAULT_DURATION_IN_MINUTES));
		}
		
		@Test
		void isOverAcceptedTimeThrowsIAEIfDurationIsLessThanZero() {
			assertThrows(IllegalArgumentException.class, ()->{service.isOverAcceptedTime(new Route(), DEFAULT_NEGATIVE_NUMBER);});
		}
		
		@Test
		void isOverAcceptedTimeThrowsIAEIfRouteIsNull() {
			assertThrows(IllegalArgumentException.class, ()->{service.isOverAcceptedTime(null, DEFAULT_DURATION_IN_MINUTES);});
		}

}
