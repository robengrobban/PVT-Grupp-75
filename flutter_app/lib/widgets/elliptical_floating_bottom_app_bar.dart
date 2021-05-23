import 'package:flutter/material.dart';

class EllipticalFloatingBottomAppBar extends StatelessWidget {
  final Widget child;

  const EllipticalFloatingBottomAppBar({Key key, this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
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
              child: child,
              notchMargin: 8,
            )));
  }

}