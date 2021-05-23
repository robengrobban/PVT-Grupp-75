import 'package:flutter/material.dart';
import 'package:flutter_app/theme.dart' as Theme;

class WhiteRoundButton extends StatelessWidget {
  final Function() onPressed;
  final icon;
  const WhiteRoundButton({this.onPressed, this.icon = Icons.add});

  @override
  Widget build(BuildContext context) {

    return ElevatedButton(
        onPressed: onPressed,
        child: Icon(
          icon,
          color: Theme.AppColors.brandPink[500],
        ),
        style: ButtonStyle(
            backgroundColor:
            MaterialStateProperty.all<Color>(Colors.white),
            minimumSize:
            MaterialStateProperty.all<Size>(Size(60, 60)),
            shape: MaterialStateProperty.all<CircleBorder>(
                CircleBorder())));
  }
}