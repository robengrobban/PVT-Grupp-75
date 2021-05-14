import 'package:location/location.dart';

class LocationHandler{

  Location location;
  LocationData _locationData;

  LocationHandler._privateConstructor();

  static final LocationHandler _instance = LocationHandler._privateConstructor();

  factory LocationHandler() {
    return _instance;
  }

  Future<void> init() async{
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.GRANTED) {
        return;
      }
    }

    _locationData = await location.getLocation();
  }


  double getLat(){
    return _locationData.latitude;
  }

  double getLon(){
    return _locationData.longitude;
  }

}