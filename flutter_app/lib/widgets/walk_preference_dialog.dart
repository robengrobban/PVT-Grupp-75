import 'package:flutter/material.dart';
import 'package:flutter_app/models/pair.dart';
import 'package:flutter_app/widgets/big_gradient_dialog.dart';
import 'package:flutter_app/widgets/white_round_button.dart';

import 'drop_down.dart';

class WalkPreferenceDialog extends StatefulWidget {
  final int initialDuration;
  final String initialAttraction;

  WalkPreferenceDialog(this.initialDuration, this.initialAttraction);

  @override
  State<StatefulWidget> createState() => _WalkPreferenceState();
}

class _WalkPreferenceState extends State<WalkPreferenceDialog> {
  static const List<int> _durations = [20, 30, 60, 90, 120];
  static const List<String> _attractions = [
    "None",
    "Cafe",
    "Church",
    "Gym",
    "Park",
    "Restaurant",
    "Supermarket"
  ];
  int _duration;

  String _attraction;

  @override
  void initState() {
    super.initState();
    _duration = widget.initialDuration;
    _attraction = widget.initialAttraction;
  }

  @override
  Widget build(BuildContext context) {
    return BigGradientDialogShell(
              title: "Route Generation Preferences",
              child: Column(
                children: [
                  Text(
                    "Walk Duration",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  DropDown<int>(
                    startValue: _duration,
                    values: _durations,
                    toText: (value) => value.toString() + " Min",
                    valueReturned: (value) {
                      _duration = value;
                    },
                  ),
                  Text(
                    "Walk Attraction",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  DropDown<String>(
                    startValue: _attraction,
                    values: _attractions,
                    toText: (value) => value,
                    valueReturned: (value) {
                      _attraction = value;
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: WhiteRoundButton(icon: Icons.check,onPressed: () {Navigator.pop(context, Pair(_duration, _attraction));}),
                  )
                ],
              )

        );
  }
}





