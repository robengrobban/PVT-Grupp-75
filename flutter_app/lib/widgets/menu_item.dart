
import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {

  final IconData _icon;
  final String _title;
  final EdgeInsets _edgeInsets;
  final Function _callback;

  MenuItem(this._icon, this._title, this._edgeInsets, this._callback);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _edgeInsets,
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.black)
        ),
        child: Container(
          margin: const EdgeInsets.all(0.0),
          child: ListTile(
              leading: Icon(_icon),
              title: Text(_title)
          ),
        ),
        onPressed: _callback,
      )
    );

  }

}
