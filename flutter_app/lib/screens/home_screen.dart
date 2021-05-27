import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/models/Medal.dart';
import 'package:flutter_app/models/Route.dart';
import 'package:flutter_app/models/account_handler.dart';
import 'package:flutter_app/models/geofence_handler.dart';
import 'package:flutter_app/models/google_maps_launcher.dart';
import 'package:flutter_app/models/location_handler.dart';
import 'package:flutter_app/models/medal_repository.dart';
import 'package:flutter_app/models/notification_handler.dart';
import 'package:flutter_app/models/pair.dart';
import 'package:flutter_app/models/performed_route.dart';
import 'package:flutter_app/models/route_handler.dart';
import 'package:flutter_app/models/user_route_handler.dart';
import 'package:flutter_app/models/weather_data.dart';
import 'package:flutter_app/models/weather_handler.dart';
import 'package:flutter_app/theme.dart' as Theme;
import 'package:flutter_app/util/shared_prefs.dart';
import 'package:flutter_app/widgets/big_gradient_dialog.dart';
import 'package:flutter_app/widgets/elliptical_floating_bottom_app_bar.dart';
import 'package:flutter_app/widgets/gradient_round_button.dart';
import 'package:flutter_app/widgets/map_info_box.dart';
import 'package:flutter_app/widgets/walk_preference_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lottie/lottie.dart';

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
  int _totalTime;
  int _totalKm;
  double _temperature;
  IconData _weatherIcon = Icons.cloud_off_outlined;
  int _initialDurationInMinutes;
  bool _routeIsActive = false;

  bool _isLoggedIn = false;

  @override
  initState() {
    super.initState();
    rootBundle
        .loadString('assets/mapStyles/darkMapStyle.txt')
        .then((string) => {_mapStyle = string});
    init();
  }

  Future<void> init() async {
    Pair<double, double> coordinates = await LocationHandler().latlon();
    _currentPosition = LatLng(coordinates.first(), coordinates.second());
    await _parsePayLoad();
    await _setUpRoute();
    await _handleSignInChange();
    await _setUpWeather();
  }

  Future<void> _parsePayLoad() async {
    if (widget.payload != null &&
        widget.payload.isNotEmpty &&
        int.tryParse(widget.payload) != null) {
      print(widget.payload);
      _initialDurationInMinutes = int.parse(widget.payload);
    }
  }

  Future<void> _setUpWeather() async {
    Pair<double, double> coordinates = await LocationHandler().latlon();
    WeatherData weatherData =
        await WeatherHandler().currentWeather(coordinates);
    if (weatherData != null) {
      _temperature = weatherData.temperature();
      _weatherIcon = weatherData.forecastIcon();
    }
  }

  Future<void> _setUpRoute() async {
    int _preferredDuration = _initialDurationInMinutes ??
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
                Navigator.of(context).pushNamed("/menu").whenComplete(() async {
                  await _handleSignInChange();
                });
              },
            )),
        title: Text("Walk in Progress"),
      ),
      extendBody: true,
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _routeIsActive ? null : GradientRoundButton(
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
                        totalTime: _totalTime,
                        totalKm: _totalKm,
                        weatherIcon: _weatherIcon,
                        temperature: _temperature,
                        isLoggedIn: _isLoggedIn),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "${_currentRoute != null ? _currentRoute.duration : 0} min ",
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            BottomAppBarButton(
              icon: Icons.star,
              onPressed: () async {
                if (!AccountHandler().isLoggedIn()) {
                  if (!await AccountHandler().handleSignIn()) return;
                }
                await _handleSignInChange();
                _saveRoute(_currentRoute);
              },
            ),
            BottomAppBarButton(
                icon: Icons.camera,
                onPressed: () {
                  Navigator.of(context).pushNamed("/camera");
                }),
            Visibility(
                child: BottomAppBarButton(icon: Icons.device_unknown_outlined),
              maintainState: true,
              maintainSize: true,
              maintainAnimation: true,
              visible: false,
            ),
            Container(width: 50, height: 50,),
            Visibility(
              maintainState: true,
              maintainSize: true,
              maintainAnimation: true,
              child: BottomAppBarButton(
                icon:   _routeIsActive ? Icons.stop : Icons.play_arrow,
                onPressed: () async {
                  if(_routeIsActive)
                    await GeoFenceHandler().stopAndClear();
                  else
                    _startRoute();
                },
              ),
              visible: _currentRoute != null,
            ),

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
    PerformedRoute route = PerformedRoute(
        waypoints: [],
        startPoint: _currentPosition,
        distance: 2500,
        actualDuration: 3600,
        timeFinished: DateTime.now());
    print(await AccountHandler().accessToken());
    print("Route saved");
  }

  Future<void> _getRoute(
      LatLng startPosition, int durationInMinutes, String attraction) async {
    context.loaderOverlay.show();
    try {
      var newRoute = await RouteHandler().fetchRoute(startPosition, durationInMinutes,
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
      print(e);
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

  Future<void> _startRoute() async {
    GeoFenceHandler().setOnRouteCompleted((performedRoute) async {
      print("FINNISHED!");
      List<Medal> medals = [];
      if (AccountHandler().isLoggedIn()) {
        UserRouteHandler().saveRoute(performedRoute);
        medals.addAll(_getEarnedMedals(performedRoute));
      }

      await _showRouteCompletedDialog(performedRoute, medals);
    });
    GeoFenceHandler().setOnRouteStopped(() {
      setState(() {
        _routeIsActive = false;
      });
    });

    GeoFenceHandler().startNew(_currentRoute).then((value) {    setState(() {
      _routeIsActive = true;
    });});
    GoogleMapsLauncher().launchWithCircularRoute(
        _currentRoute.startPoint, _currentRoute.waypoints);
  }

  Future<void> _handleSignInChange() async {
    setState(() {
      print("Logged in " + AccountHandler().isLoggedIn().toString());
      _isLoggedIn = AccountHandler().isLoggedIn();
    });
    if (_isLoggedIn) {
      int time = await UserRouteHandler().getTotalTimeWalked() ~/ (60 * 60);
      int km = await UserRouteHandler().getTotalDistanceWalked() ~/ 1000;
      setState(() {
        _totalTime = time;
        _totalKm = km;
      });
    }
  }

  Future<void> _showRouteCompletedDialog(
      PerformedRoute route, List<Medal> medals) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return BigGradientDialogShell(
            title: "Good job!",
            titleSize: 24,
            showArrow: false,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Lottie.asset('assets/images/firework-animation.json',
                  width: 70, height: 70),
              Text("You finished your walk",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              Text("Duration: ${route.actualDuration ~/ 60} min",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("Distance: ${(route.distance / 1000).toStringAsFixed(2)} km",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              if(medals.isNotEmpty) Padding(
                padding: EdgeInsets.only(top:20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("You also earned ${medals.length} medals!",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: Theme.AppColors.brandOrange[900].withOpacity(0.5),),
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(top:10),
                      height: medals.length * 55.0,
                      width: 250,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: medals.length,
                        itemBuilder: (context, index) {
                          return Row(children: [
                            ShaderMask(
                              child: ImageIcon(
                                AssetImage('assets/images/141054.png'),
                                size: 50,
                                color: MedalRepository().getColor(medals[index].type, medals[index].value),
                              ),
                              shaderCallback: (Rect bounds) {
                                return LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    MedalRepository().getColor(medals[index].type, medals[index].value)
                                  ],
                                  stops: [0.0, 0.5],
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.srcIn,
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(MedalRepository().getDescription(medals[index].type, medals[index].value)),
                            )
                          ]);
                        }),
                      ),

                  ]
                ),
              )

            ]),
          );
        });
  }

  List<Medal> _getEarnedMedals(PerformedRoute performedRoute) {
    return [];
  }


}

class HomeInfoRow extends StatelessWidget {
  const HomeInfoRow({
    Key key,
    @required int totalTime,
    @required int totalKm,
    @required IconData weatherIcon,
    @required double temperature,
    @required bool isLoggedIn,
  })  : _totalTime = totalTime,
        _totalKm = totalKm,
        _weatherIcon = weatherIcon,
        _temperature = temperature,
        _isLoggedIn = isLoggedIn,
        super(key: key);

  final int _totalTime;
  final int _totalKm;
  final IconData _weatherIcon;
  final double _temperature;
  final bool _isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Visibility(
            child: InfoBox(Icons.timelapse_rounded, "TOTAL H",
                _totalTime.toString() + " h"),
            visible: _isLoggedIn,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
          ),
          Visibility(
              child: InfoBox(Icons.directions_walk, "TOTAL KM",
                  _totalKm.toString() + " km"),
              visible: _isLoggedIn,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true),
          InfoBox(
              _weatherIcon,
              "WEATHER",
              (_temperature == null ? "?" : _temperature.toString()) +
                  "\u00B0"),
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
