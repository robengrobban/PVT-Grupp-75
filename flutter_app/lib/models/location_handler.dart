import 'package:flutter_app/models/pair.dart';
import 'package:location/location.dart';

class LocationHandler{

  Location _location;
  LocationData _locationData;

  bool _initialized = false;

  static final Pair<double, double> _noLocationFound = new Pair(0.0, 0.0);

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

    _initialized = true;
  }


  Future<Pair<double, double>> latlon() async{
    //if(!_initialized){
    //  return _noLocationFound;
    //} TEMPORÄRT
    _locationData = await _location.getLocation();
    Pair<double, double> latLonPair = new Pair(_locationData.latitude, _locationData.longitude);

    return latLonPair;
  }

  /*double getLat(){
    if(!_initialized){
      return 0.0;
    }
    return _locationData.latitude;
  }

  double getLon(){
    if(!_initialized){
      return 0.0;
    }

    return _locationData.longitude;
  }
  */
  
  bool isInitialized(){
    return _initialized;
  }


}