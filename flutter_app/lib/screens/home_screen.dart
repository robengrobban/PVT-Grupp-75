import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/models/Route.dart';
import 'package:flutter_app/models/account_handler.dart';
import 'package:flutter_app/models/location_handler.dart';
import 'package:flutter_app/models/pair.dart';
import 'package:flutter_app/models/route_handler.dart';
import 'package:flutter_app/models/weather_handler.dart';
import 'package:flutter_app/theme.dart' as Theme;
import 'package:flutter_app/util/shared_prefs.dart';
import 'package:flutter_app/widgets/elliptical_floating_bottom_app_bar.dart';
import 'package:flutter_app/widgets/gradient_round_button.dart';
import 'package:flutter_app/widgets/map_info_box.dart';
import 'package:flutter_app/widgets/walk_preference_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:loader_overlay/loader_overlay.dart';

class HomeScreen extends StatefulWidget {
  final String payload;

  HomeScreen({this.payload});

  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const DEFAULT_ATTRACTION = "None";
  static const DEFAULT_DURATION = 20;
  GoogleMapController _mapController;
  String _mapStyle;
  CircularRoute _currentRoute;
  LatLng _currentPosition = LatLng(58, 17);
  int _calories = 729;
  int _steps = 3526;
  double _temperature = null;
  IconData _weatherIcon = Icons.cloud_off_outlined;
  int initialDurationInMinutes;
  bool loggedIn;

  @override
  initState() {
    super.initState();
    if (widget.payload != null &&
        widget.payload.isNotEmpty &&
        int.tryParse(widget.payload) != null) {
      initialDurationInMinutes = int.parse(widget.payload);
    }
    LocationHandler().latlon().then((coordinates) {
      WeatherHandler().currentWeather( coordinates ).then((value) {
        _temperature = value.temperature();
        _weatherIcon = value.forecastIcon();
      });
    });
    rootBundle
        .loadString('assets/mapStyles/darkMapStyle.txt')
        .then((string) => {_mapStyle = string});
    _setUpRoute();
  }

  void _setUpRoute() async {
    _currentPosition = LatLng(58.9142, 17.9380);
    int _preferredDuration = initialDurationInMinutes ??
        (SharedPrefs().preferredDuration ?? DEFAULT_DURATION);
    String _preferredAttraction =
        SharedPrefs().preferredAttraction ?? DEFAULT_ATTRACTION;
    await _getRoute(_currentPosition, _preferredDuration, _preferredAttraction);
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
                Navigator.of(context)
                    .pushNamed("/menu")
                    .whenComplete(() => null);
              },
            )),
        title: Text("Walk in Progress"),
      ),
      extendBody: true,
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GradientRoundButton(
          icon: Icons.add,
          onPressed: () async {
            await _getNewRoute();
          }),
      body: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(gradient: Theme.appGradiant),
          child: Stack(children: [
            GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: _currentPosition, zoom: 15),
              zoomControlsEnabled: false,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              polylines: _currentRoute != null
                  ? Set<Polyline>.of({
                      Polyline(
                        polylineId: PolylineId("route"),
                        points: _currentRoute.polyCoordinates,
                        color: Theme.AppColors.brandOrange[500],
                      )
                    })
                  : Set.of([]),
              onMapCreated: (controller) async {
                _mapController = controller;
                _mapController.setMapStyle(_mapStyle);
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  _updateMapCamera();
                });
                setState(() {
                  _getCurrentLocation();
                });
              },
            ),
            Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    HomeInfoRow(
                        steps: _steps,
                        calories: _calories,
                        weatherIcon: _weatherIcon,
                        temperature: _temperature),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "${_currentRoute != null ? _currentRoute.duration : 0} min",
                            style: TextStyle(
                                color: Theme.AppColors.brandOrange[500],
                                fontSize: 36),
                          ),
                        ))
                  ],
                )),
          ])),
      bottomNavigationBar: EllipticalFloatingBottomAppBar(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  BottomAppBarButton(
                    icon: Icons.star,
                    onPressed: () async {
                      if (!AccountHandler().isLoggedIn()) {
                        if (!await AccountHandler().handleSignIn()) return;
                      }
                      _saveRoute(_currentRoute);
                    },
                  ),
                  BottomAppBarButton(
                      icon: Icons.camera,
                      onPressed: () {
                        Navigator.of(context).pushNamed("/camera");
                      }),
                ],
              ),
            ),
            Spacer(),
            Expanded(
              flex: 2,
              child: Center(
                child: ElevatedButton(style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                  elevation: MaterialStateProperty.all(15),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30))
                  )),
                  shadowColor: MaterialStateProperty.all(Theme.AppColors.brandOrange[100]),

                ),

                  child: Icon(Icons.play_arrow, color: Colors.green, size: 40,),
                  onPressed: (){_startRoute();},
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _getNewRoute() async {
    await _getCurrentLocation();
    Pair result = await _showWalkPreferenceDialog();
    if (result != null) {
      await _getRoute(_currentPosition, result.first(), result.second());
      context.loaderOverlay.hide();
    }
  }

  Future<void> _getCurrentLocation() async {
    await LocationHandler().latlon().then((currentData) => {
          setState(() {
            _currentPosition =
                LatLng(currentData.first(), currentData.second());
          })
        });
  }

  Future<void> _updateMapCamera() async {
    if (_currentRoute != null) {
      await _mapController?.animateCamera(CameraUpdate.newLatLngBounds(
          LatLngBounds(
              southwest: _currentRoute.southWestBound,
              northeast: _currentRoute.northEastBound),
          100));
    } else {
      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target:
                LatLng(_currentPosition.latitude, _currentPosition.longitude),
            zoom: 15.0,
          ),
        ),
      );
    }
  }

  Future<Pair> _showWalkPreferenceDialog() async {
    Pair results = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return WalkPreferenceDialog(
              SharedPrefs().preferredDuration ?? DEFAULT_DURATION,
              SharedPrefs().preferredAttraction ?? DEFAULT_ATTRACTION);
        });
    if (results != null) {
      SharedPrefs().preferredDuration = results.first();
      SharedPrefs().preferredAttraction = results.second();
    }

    return results;
  }

  Future<CircularRoute> _saveRoute(CircularRoute route) async {
    print("Route saved");
  }

  Future<void> _getRoute(
      LatLng startPosition, int durationInMinutes, String attraction) async {
    context.loaderOverlay.show();
    try {
      var newRoute = await RouteHandler().fetchRoute(
          startPosition, durationInMinutes,
          attraction: attraction.toLowerCase() == "none" ? null : attraction,
          unwantedRoute: _currentRoute);
      if (newRoute != null) {
        setState(() {
          _currentRoute = newRoute;
          _updateMapCamera().then((value) => context.loaderOverlay.hide());
        });
      } else {
        context.loaderOverlay.hide();
        await _showMapLoadErrorDialog(
            "We are having a hard time finding a route for you, you may try your luck again or modify your settings for better chances 🐜");
      }
    } catch (e) {
      context.loaderOverlay.hide();
      await _showMapLoadErrorDialog(
          "Some unknown error occurred, please try again");
    }
  }

  Future<void> _showMapLoadErrorDialog(String message) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(children: [
              Icon(
                Icons.error,
                color: Colors.red[900],
              ),
              Text("Unable to load map")
            ]),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(fontSize: 24),
                ),
              ),
              TextButton(
                  onPressed: () {
                    _getNewRoute();
                    Navigator.pop(context);
                  },
                  child: Text("Retry", style: TextStyle(fontSize: 24)))
            ],
          );
        });
  }

  _startRoute() {
  }
}

class HomeInfoRow extends StatelessWidget {
  const HomeInfoRow({
    Key key,
    @required int steps,
    @required int calories,
    @required IconData weatherIcon,
    @required double temperature,
  })  : _steps = steps,
        _calories = calories,
        _weatherIcon = weatherIcon,
        _temperature = temperature,
        super(key: key);

  final int _steps;
  final int _calories;
  final IconData _weatherIcon;
  final double _temperature;

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InfoBox(Icons.directions_walk, "STEPS", _steps.toString()),
          InfoBox(Icons.fastfood, "CALORIES", _calories.toString()),
          InfoBox(_weatherIcon, "WEATHER", (_temperature == null ? "?" : _temperature.toString()) + "\u00B0"),
        ]);
  }
}

class BottomAppBarButton extends StatelessWidget {
  final Function() onPressed;
  final IconData icon;

  const BottomAppBarButton({Key key, this.onPressed, this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        disabledColor: Colors.grey,
        color: Theme.AppColors.brandOrange[400],
        icon: Icon(icon, size: 40),
        onPressed: onPressed);
  }
}
