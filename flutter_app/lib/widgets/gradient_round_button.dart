import 'package:flutter/material.dart';
import 'package:flutter_app/theme.dart' as Theme;

class GradientRoundButton extends StatelessWidget {
  final Function() onPressed;
  final icon;
  const GradientRoundButton({this.onPressed, this.icon = Icons.add});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        child: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: Theme.appGradiant),
          child: Icon(
            icon,
            size: 36,
            color: Colors.white,
          ),
        ),
        onPressed: onPressed
    );
  }

}