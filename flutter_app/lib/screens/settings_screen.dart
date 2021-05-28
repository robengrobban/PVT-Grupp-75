import 'package:flutter/material.dart';
import 'package:flutter_app/models/notification_handler.dart';
import 'package:flutter_app/widgets/settings_numberpicker.dart';
import 'package:flutter_app/theme.dart' as Theme;

class SettingScreen extends StatefulWidget {
  @override
  State createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {

  int _walkLengthValue = NotificationHandler().walkLength();
  int _noNotificationsValue = NotificationHandler().maxNotifications();
  bool _currentAffectedByWeather;


  @override
  void initState() {
    super.initState();
    _currentAffectedByWeather = NotificationHandler().affectedByWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Notification settings"),
        ),
        backgroundColor: Colors.white,
        body: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(gradient: Theme.appGradiant),
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints viewportConstraints) {
                  return SingleChildScrollView(
                      padding: EdgeInsets.all(32.0),
                      child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: viewportConstraints.maxHeight,
                          ),
                          child: Form(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Column(
                                    children: <Widget>[
                                      Text(
                                        "Number of scheduled notifications",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16),
                                      ),
                                      SettingsNumberPicker(_noNotificationsValue, 0, 3, _setNoNotifications, axis: Axis.horizontal,),
                                    ]
                                ),
                                Column(
                                  children: <Widget>[
                                    Text(
                                        "Preferred walk length in minutes",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                    )
                                    ),
                                    SettingsNumberPicker(_walkLengthValue, 20, 120, _setWalkLength, stepSize: 5,)
                                    ],
                                ),
                                Column(
                                  children: <Widget>[
                                    Text(
                                        "Weather affects notifications",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        )
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                        ),
                                        child: ToggleButtons(
                                          children: [
                                            Icon(_affectedIcon())
                                          ],
                                          onPressed: _toggleAffectedByWeather,
                                          isSelected: [_currentAffectedByWeather],
                                          selectedColor: Colors.green,
                                          color: Colors.red,

                                          selectedBorderColor: Colors.black,
                                          borderColor: Colors.black,

                                          fillColor: Colors.transparent,
                                          borderWidth: 1,
                                        ),
                                      )
                                    )],
                                ),
                                ElevatedButton(
                                  child: Text("Save"),
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                      //shadowColor: MaterialStateProperty.all<Color>(Colors.transparent)
                                  ),
                                  onPressed: _saveActions,
                                )
                              ],
                            )
                          )
                      )
                  );
                }
            )
        )
    );
  }

  void _toggleAffectedByWeather(int index) {
    setState(() {
      _currentAffectedByWeather = !_currentAffectedByWeather;
    });
  }

  IconData _affectedIcon() {
    return _currentAffectedByWeather ? Icons.cloud_outlined : Icons.cloud_off_outlined;
  }

  void _setNoNotifications(int newValue){
    setState(() {
      _noNotificationsValue = newValue;
    });
  }

  void _setWalkLength(int newValue){
    setState(() {
      _walkLengthValue = newValue;
    });
  }
  void _saveActions() {
    try {
      int newMaxNotifications = _noNotificationsValue;
      int newWalkLength = _walkLengthValue;
      bool newAffectedByWeather = _currentAffectedByWeather;
      NotificationHandler().updateSettings(newMaxNotifications, newWalkLength, newAffectedByWeather);
      final snackBar = SnackBar(
        content: Text('Settings updated!')
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    catch(e) {
      print("There are 🐜🐜🐜 in the spooky setting screen");
      print(e);
    }
  }


}