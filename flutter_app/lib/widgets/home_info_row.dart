
import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/map_info_box.dart';

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