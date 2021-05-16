import 'package:location/location.dart';

class LocationHandler{

  Location _location;
  LocationData _locationData;

  bool _initialized = false;

  static const double _noLocationFound = 0.0;

  static final LocationHandler _instance = LocationHandler._privateConstructor();

  LocationHandler._privateConstructor();

  factory LocationHandler() {
    return _instance;
  }

  Future<void> init() async{
    _location =  new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.GRANTED) {
        return;
      }
    }

    _locationData = await _location.getLocation();
    _initialize();
  }


  double getLat(){
    if(!_initialized){
      return _noLocationFound;
    }
    return _locationData.latitude;
  }

  double getLon(){
    if(!_initialized){
      return _noLocationFound;
    }
    return _locationData.longitude;
  }

  bool isInitialized(){
    return _initialized;
  }

  void _initialize(){
    _initialized = true;
    return;
  }

}