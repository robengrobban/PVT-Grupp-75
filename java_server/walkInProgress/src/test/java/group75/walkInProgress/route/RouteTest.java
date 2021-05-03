package group75.walkInProgress.route;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;

import com.google.maps.model.Bounds;
import com.google.maps.model.DirectionsLeg;
import com.google.maps.model.DirectionsRoute;
import com.google.maps.model.LatLng;
import com.mysql.cj.exceptions.StatementIsClosedException;
import com.mysql.cj.xdevapi.Schema.CreateCollectionOptions;

import antlr.collections.List;

class RouteTest {
	private static final LatLng DEFAULT_STARTPOINT_LAT_LNG = new LatLng(50.8, 17.6);
	private static final double DEFAULT_LEG_DISTANCE = 5;
	private static final double DEFAULT_ANGLE_IN_RADIANS = 1;
	private static final double DEFAULT_DISTANCE = 5;
}
