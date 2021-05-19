import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/models/Route.dart';
import 'package:flutter_app/models/pair.dart';
import 'package:flutter_app/models/weather_handler.dart';
import 'package:flutter_app/theme.dart' as Theme;
import 'package:flutter_app/widgets/map_info_box.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_icons/weather_icons.dart';

class HomeScreen extends StatefulWidget {
  final int initialDurationInMinutes;
  HomeScreen({this.initialDurationInMinutes});
  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController _mapController;
  String _mapStyle;
  var _loc = Location();
  int _numberOfRouteTries = 0;
  CircularRoute _currentRoute;
  int _preferredDuration = 20;
  String _preferredAttraction = "None";
  LatLng _currentPosition = LatLng(58, 17);
  int _calories = 729;
  int _steps = 3526;
  double _temperature = 17.1;
  IconData _weatherIcon = Icons.cloud_off_outlined;

  @override
  initState() {
    super.initState();
    WeatherHandler().currentWeather().then((value) {
      _temperature = value.temperature();
      print(_temperature);
      _weatherIcon = value.forecastIcon();
    });
    rootBundle
        .loadString('assets/mapStyles/darkMapStyle.txt')
        .then((string) => {_mapStyle = string});
    _setUpRoute();
  }

  void _setUpRoute() async {
    context.loaderOverlay.show();
    _currentPosition = LatLng(58.9142, 17.9380);

    if(widget.initialDurationInMinutes == null) {
      _getDurationFromPreferences();
    } else {
      _preferredDuration = widget.initialDurationInMinutes;
    }
    _getAttractionFromPreferences();
    await fetchRoute(_currentPosition, _preferredDuration, _preferredAttraction);

    context.loaderOverlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: Padding(
              padding: EdgeInsets.all(8.0),
              child: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Navigator.of(context).pushNamed("/menu");
                },
              )),
          title: Text("Walk in Progress"),
        ),
        backgroundColor: Colors.white,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.AppColors.brandPink[500],
                      Theme.AppColors.brandOrange[500]
                    ],
                  )),
              child: Icon(
                Icons.add,
                size: 20,
                color: Colors.white,
              ),
            ),
            onPressed: () async {
              await _getCurrentLocation();
              Pair result = await _showWalkPreferenceDialog();
              if (result != null) {
                context.loaderOverlay.show();
                  fetchRoute(
                      _currentPosition, result.first(), result.second());
                context.loaderOverlay.hide();
              }
            }),
        body: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.AppColors.brandPink[500],
                Theme.AppColors.brandOrange[500]
              ],
            )),
            child: Stack(children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(target: _currentPosition, zoom: 15),
                zoomControlsEnabled: false,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                polylines: _currentRoute != null ? Set<Polyline>.of({
                  Polyline(
                    polylineId: PolylineId("route"),
                    points: _currentRoute.polyCoordinates,
                    color: Theme.AppColors.brandOrange[500],
                  )
                }) : Set.of([]),
                onMapCreated: (controller) async {
                  _mapController = controller;
                  _mapController.setMapStyle(_mapStyle);
                  setState(() {
                    _getCurrentLocation();
                  });
                },
              ),
              Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InfoBox(Icons.directions_walk, "STEPS",
                                _steps.toString()),
                            InfoBox(Icons.fastfood, "CALORIES",
                                _calories.toString()),
                            InfoBox(_weatherIcon, "WEATHER",
                                _temperature.toString() + "\u00B0"),
                          ]),
                      Align(alignment: Alignment.topLeft,
                          child:Container(color: Colors.white54, padding: EdgeInsets.all(10), margin: EdgeInsets.all(10), width: 100,

                      child: Text("${_currentRoute != null ? _currentRoute.duration : 0} min")))
                    ],
                  )),
            ])),
        bottomNavigationBar: Container(
            height: 60,
            margin: EdgeInsets.only(bottom: 30),
            child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.elliptical(100, 100),
                    topRight: Radius.elliptical(100, 100),
                    bottomLeft: Radius.elliptical(100, 100),
                    bottomRight: Radius.elliptical(100, 100)),
                child: BottomAppBar(
                  shape: CircularNotchedRectangle(),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Spacer(flex: 2),
                      IconButton(
                          icon: Icon(Icons.star,
                              size: 40,
                              color: Theme.AppColors.brandOrange[400]),
                          onPressed:() {_saveRoute(_currentRoute);}),
                      Spacer(flex: 1),
                      IconButton(
                          icon: Icon(Icons.people,
                              size: 40,
                              color: Theme.AppColors.brandOrange[400]),
                          onPressed: null),
                      Spacer(flex: 4),
                      IconButton(
                          icon: Icon(Icons.camera,
                              size: 40,
                              color: Theme.AppColors.brandOrange[400]),
                          onPressed: (){Navigator.of(context).pushNamed("/camera");}),
                      Spacer(flex: 1),
                      IconButton(
                          icon: Icon(Icons.music_note,
                              size: 40,
                              color: Theme.AppColors.brandOrange[400]),
                          onPressed: null),
                      Spacer(flex: 2),
                    ],
                  ),
                  notchMargin: 8,
                ))),
        extendBody: true);
  }

  Future<void>_getDurationFromPreferences() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int res = prefs.getInt('preferredDuration');
      if( res != null) {
        setState(() {
          _preferredDuration = res;
        });
      }
  }

  Future<void> _getAttractionFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String res = prefs.getString('preferredAttraction');
    if( res != null) {
      setState(() {
        _preferredAttraction = res;
      });
    }
  }

  Future<void>_getCurrentLocation() async {
    await _loc.getLocation().then((currentData) => {
    setState(() {
    _currentPosition = LatLng(currentData.latitude, currentData.longitude);
    })
  });

  }

  void _moveMapToBound() {
    print("nELa: " +
        _currentRoute.northEastBound.latitude.toString() +
        " neLo " +
        _currentRoute.northEastBound.longitude.toString());
    print("nELa: " +
        _currentRoute.southWestBound.latitude.toString() +
        " neLo " +
        _currentRoute.southWestBound.longitude.toString());
    _mapController.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: _currentRoute.southWestBound, northeast: _currentRoute.northEastBound),
        100));
  }

  Future<Pair> _showWalkPreferenceDialog() {
    int _duration = 20;
    String _attraction = "Park";
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              contentTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50))),
              contentPadding: EdgeInsets.all(0),
              content: Container(
                padding:
                    EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.AppColors.brandPink[500],
                        Theme.AppColors.brandOrange[500]
                      ],
                    )),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Route Generation Preferences",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Divider(
                      color: Colors.black26,
                      indent: 20,
                      endIndent: 20,
                      thickness: 2,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: BackButton(
                            color: Colors.white,
                          )),
                    ),
                    Text(
                      "Walk Duration",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5)),
                        padding: EdgeInsets.only(left: 10, right: 10),
                        margin: EdgeInsets.all(20),
                        child: DropdownButton(
                          underline: SizedBox(),
                          value: _duration,
                          items: <int>[20, 30, 60, 90, 120]
                              .map<DropdownMenuItem<int>>((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Container(
                                  width: 150,
                                  child: Text(value.toString() + " Min",
                                      style: TextStyle(fontSize: 16))),
                            );
                          }).toList(),
                          iconSize: 24,
                          onChanged: (value) {
                            setState(() {
                              _duration = value;
                            });
                          },
                        )),
                    Text(
                      "Walk Attraction",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5)),
                        padding: EdgeInsets.only(left: 10, right: 10),
                        margin: EdgeInsets.all(20),
                        child: DropdownButton(
                          underline: SizedBox(),
                          value: _attraction,
                          items: <String>[
                            "None",
                            "Cafe",
                            "Church",
                            "Gym",
                            "Park",
                            "Restaurant",
                            "Supermarket"
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Container(
                                  width: 150,
                                  child: Text(value,
                                      style: TextStyle(fontSize: 16))),
                            );
                          }).toList(),
                          iconSize: 24,
                          onChanged: (value) {
                            setState(() {
                              _attraction = value;
                            });
                          },
                        )),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: ElevatedButton(
                          onPressed: () => {
                                Navigator.pop(
                                    context, Pair(_duration, _attraction))
                              },
                          child: Icon(
                            Icons.check,
                            color: Theme.AppColors.brandPink[500],
                          ),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              minimumSize:
                                  MaterialStateProperty.all<Size>(Size(60, 60)),
                              shape: MaterialStateProperty.all<CircleBorder>(
                                  CircleBorder()))),
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  CircularRoute _parseRoute(String responseBody) {
    Map<String, dynamic> route = jsonDecode(responseBody);
    return CircularRoute.fromJson(route);
  }
  Future<CircularRoute> _saveRoute(CircularRoute route) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var stringRoutes = prefs.getString("Routes");
    List<CircularRoute> routes = List.of({});
    if (stringRoutes != null) {
      for(var d in jsonDecode(stringRoutes)) {
        routes.add(CircularRoute.fromJson(d));
      }
      (routes.forEach((element) {print("${element.distance}" + " distance is here"); }));
    }
    routes.add(route);
    prefs.setString('Routes', jsonEncode(routes));

  }

  void fetchRoute(
      LatLng startPosition, int durationInMinutes, String attraction) async {
    attraction.replaceAll(" ", "_");
    _numberOfRouteTries++;
    var angle = Random().nextDouble() * pi * 2;
    var uri = Uri(
        scheme: 'https',
        host: 'group5-75.pvt.dsv.su.se',
        path: 'route/generate',
        query:
            'lat=${startPosition.latitude}&lng=${startPosition.longitude}&duration=$durationInMinutes&radians=$angle${attraction.toLowerCase() != "none" ? "&type=$attraction" : ""}');
    print(uri.toString());
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      _numberOfRouteTries = 0;
      setState(() {
        _currentRoute = _parseRoute(response.body);
        _moveMapToBound();
      });


    } else if (response.statusCode == 404 && _numberOfRouteTries < 10) {
      return fetchRoute(startPosition, durationInMinutes, attraction);
    } else {
      setState(() {
        _currentRoute = null;
      });

      print(response.statusCode);
      context.loaderOverlay.hide();
      throw Exception('Unable to fetch products from the REST API');
    }
    setState(() {

    });
  }


}
