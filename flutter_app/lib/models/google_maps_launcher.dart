import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_launcher/map_launcher.dart' as ml;

class GoogleMapsLauncher {
  static final GoogleMapsLauncher _launcher = GoogleMapsLauncher._internal();

  factory GoogleMapsLauncher() => _launcher;

  GoogleMapsLauncher._internal();

  Future launchWithCircularRoute(LatLng startPoint, List<LatLng> points) async {
    List<ml.Coords> waypoints = [];
    points.forEach((point) {
      waypoints.add(ml.Coords(point.latitude, point.longitude));
    });
  print("waypoints to google: $waypoints");
    if (await ml.MapLauncher.isMapAvailable(ml.MapType.google)) {
      await ml.MapLauncher.showDirections(
          mapType: ml.MapType.google,
          origin: ml.Coords(startPoint.latitude, startPoint.longitude),
          destination: ml.Coords(startPoint.latitude, startPoint.longitude),
          directionsMode: ml.DirectionsMode.walking,
          waypoints: waypoints);
    }
  }
}
