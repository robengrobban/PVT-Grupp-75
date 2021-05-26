import 'package:flutter/material.dart';
import 'package:flutter_app/theme.dart' as Theme;

class InfoBox extends StatelessWidget {

  final IconData _icon;
  final String _title;
  final String _value;

  InfoBox(this._icon, this._title, this._value);

  @override
  Widget build(BuildContext context) {
    return Container(
      height:50,
      width:100,
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Theme.AppColors.brandPink[50],
                blurRadius: 6,
                offset: Offset(0, 2)),
            BoxShadow(
                color: Theme.AppColors.brandOrange[50],
                blurRadius: 8,
                offset: Offset(0, 4)),
          ]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
                _icon,
                color: Theme.AppColors.brandOrange[500],
              size: 15,
            ),
            Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      _title,
                      style: TextStyle (
                        letterSpacing: 1.2,
                        fontSize: 12
                      )
                  ),
                  Text(_value,
                      style: TextStyle (
                      letterSpacing: 1.2,
                      fontSize: 16,
                        fontWeight: FontWeight.bold
                  )),
                ]
            )
          ]
      ),
    );
  }

}
