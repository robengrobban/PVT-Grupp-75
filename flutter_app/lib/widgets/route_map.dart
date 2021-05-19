import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/models/Route.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_app/theme.dart' as Theme;

class RouteMap extends StatefulWidget {
  
  final CircularRoute currentRoute;
  final LatLng position;
  RouteMap({this.currentRoute, this.position});
  

  @override
  State createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  static const DEFAULT_START_POINT = LatLng(59.3353, 18.0644);
  static const DEFAULT_ZOOM_LEVEL = 15.0;
  Completer<GoogleMapController> _mapController = Completer();
  String _mapStyle;

  @override
  initState() {
    super.initState();
    rootBundle
        .loadString('assets/mapStyles/darkMapStyle.txt')
        .then((string) => {_mapStyle = string});
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: _getStartPosition(), zoom: DEFAULT_ZOOM_LEVEL),
      zoomControlsEnabled: false,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      polylines: _getPolylines(),
      onMapCreated: (controller) async {
        controller.setMapStyle(_mapStyle);
        _mapController.complete(controller);

        _updateCamera();
      },
    );
  }

  LatLng _getStartPosition() {
    if(widget.currentRoute != null) {
        return widget.currentRoute.startPoint;
    } else if (widget.position != null) {
      return widget.position;
    } else {
      return DEFAULT_START_POINT;
    }
  }

  Set<Polyline> _getPolylines() {
    if(widget.currentRoute == null) {
        return Set();
    } else {
      return Set<Polyline>.of({
        Polyline(
          polylineId: PolylineId("route"),
          points: widget.currentRoute.polyCoordinates,
          color: Theme.AppColors.brandOrange[500],
        )
      });
    }
}

  Future<void> _updateCamera() async {
    var contr = await _mapController.future;
    if(widget.currentRoute != null) {
        contr.animateCamera(CameraUpdate.newLatLngBounds(
            LatLngBounds(southwest: widget.currentRoute.southWestBound, northeast: widget.currentRoute.northEastBound),
            100));

    } else {
      LatLng position = DEFAULT_START_POINT;
      if (widget.position != null) {
        position = widget.position;
      }
            contr.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: position,
              zoom: DEFAULT_ZOOM_LEVEL,
            ),
          ),
        );
    }
  }
}