
import 'package:flutter_app/theme.dart' as Theme;
import 'package:flutter/material.dart';

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