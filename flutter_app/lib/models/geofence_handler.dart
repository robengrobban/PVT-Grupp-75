import 'package:flutter_app/models/performed_route.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'Route.dart';
import 'notification_handler.dart';

class GeoFenceHandler {
  static Set<int> _passed = Set();
  static Set<int> _toPass = Set();
  static bool _passedStartTwice = false;
  static Function(PerformedRoute) _onRouteCompleted = (_){};
  static Function() _onRouteStopped = (){};
  static DateTime _startTime;
  static CircularRoute _activeRoute;

  static final GeoFenceHandler _geoFencer = GeoFenceHandler._internal();

  factory GeoFenceHandler () => _geoFencer;

  GeoFenceHandler._internal();

  Future<void> init() async {
    bg.BackgroundGeolocation.onGeofence((bg.GeofenceEvent event) async {
      await _handleGeoFenceEvent(event);
    });
    bg.BackgroundGeolocation.onEnabledChange((isEnabled) async {
      print("PERFORMING MANUALLY)${_toPass.length}");
      if(!isEnabled && _toPass.isNotEmpty) {
        NotificationHandler().send(666, "Tracking of walk stopped", "The walk you were taking is no longer tracked, this might be due to too much time passing or due to some unknown error");
        stopAndClear();
      }
    });
    await _configure();
  }

  Future _handleGeoFenceEvent(bg.GeofenceEvent event) async {
    _passed.add(int.parse(event.identifier));
    NotificationHandler().send(int.parse(event.identifier), "Past a point", "count is ${_passed.length} of ${_toPass.length}");
    print("Passed: $_passed topass: $_toPass");
    if(_passed.containsAll(_toPass)) {
      if(!_passedStartTwice) {
        _passed.remove(1000);
        NotificationHandler().send(999, "Pass start again", "count is ${_passed.length} of ${_toPass.length}");
        _passedStartTwice = true;
      } else {
        int actualDuration = DateTime.now().difference(_startTime).inSeconds;
        PerformedRoute performedRoute = PerformedRoute(waypoints: _activeRoute.waypoints, startPoint: _activeRoute.startPoint, distance: _activeRoute.distance, actualDuration: actualDuration, timeFinished: DateTime.now());
        _onRouteCompleted(performedRoute);
        NotificationHandler().send(42, "You finished the route", "Good job!");
        await stopAndClear();
      }
    }
  }

  Future _configure() async {
    await bg.BackgroundGeolocation.ready(bg.Config(
        geofenceModeHighAccuracy: true,
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        reset: true,
        distanceFilter: 5.0,
        stopOnTerminate: true,
        foregroundService: true,
        startOnBoot: false,
        stopAfterElapsedMinutes: 180,
        locationAuthorizationRequest: 'Always',
        backgroundPermissionRationale: bg.PermissionRationale(
            title: "Allow {applicationName} to access to this device's location in the background?",
            message: "In order to track your activity in the background, please enable {backgroundPermissionOptionLabel} location permission",
            positiveAction: "Change to {backgroundPermissionOptionLabel}",
            negativeAction: "Cancel"
        ),
        debug: true,
        notification: bg.Notification(
            title: "Walk In Progress",
            text: "Keep Walking"
        )
    )).then((value) => print("configured: ${value.enabled}"));

  }

  Future<void> stopAndClear() async {
    _activeRoute = null;
    _startTime = null;
    _passedStartTwice = false;
    _passed.clear();
    _toPass.clear();
    await bg.BackgroundGeolocation.removeGeofences().then((bool success) {
      print('[removeGeofences] all geofences have been destroyed');
    });
    await bg.BackgroundGeolocation.stop().then((state) {
      print('State is ${state.enabled}');
    });
    _onRouteStopped();
  }

  Future<void> startNew(CircularRoute route) async {
    await stopAndClear();
    _activeRoute = route;
    _startTime = DateTime.now();
    await _addGeoFence(1000, route.startPoint);
    int step = route.polyCoordinates.length ~/ 10 + 1;
    for (int i = step; i < route.polyCoordinates.length - step;i += step) {
      await _addGeoFence(1000+i, route.polyCoordinates[i]);
    }
    NotificationHandler().send(21, "Have a nice walk", "${_toPass.length} points created");
    await bg.BackgroundGeolocation.startGeofences().then((
        value) => "state is ${value.enabled}");
  }

    Future<void> _addGeoFence(int id, LatLng point) async {
      await bg.BackgroundGeolocation.addGeofence(bg.Geofence(notifyOnEntry: true,identifier: "$id", radius: 100, latitude: point.latitude, longitude: point.longitude)).then((bool success) {
        _toPass.add(id);
        print('[addGeofences] success: $success');
      }).catchError((dynamic error) => {
        print('[addGeofences] FAILURE: $error')
      });
    }
    
    setOnRouteCompleted(Function(PerformedRoute) onRouteCompleted) {
      _onRouteCompleted = onRouteCompleted;
    }

  setOnRouteStopped(Function() onRouteStopped) {
    _onRouteStopped = onRouteStopped;
  }


}