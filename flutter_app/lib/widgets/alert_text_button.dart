import 'package:flutter/material.dart';
import 'package:flutter_app/theme.dart';

class AlertTextButton extends StatelessWidget {

  final String text;
  final Function callback;
  final bool highLit;

  AlertTextButton(this.text, this.callback, this.highLit);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ElevatedButton(
          style: highLit? ButtonStyle() : ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent), shadowColor: MaterialStateProperty.all(Colors.transparent)),
          child: Text(text,
            style: highLit? TextStyle() : TextStyle(color: AppColors.brandPink[500])
            ),

          onPressed: callback,

        )
    );

  }

}