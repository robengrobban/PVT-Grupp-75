import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/models/notification_handler.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter_app/theme.dart' as Theme;

class SettingScreen extends StatefulWidget {
  @override
  State createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {

  //TextEditingController _maxNotificationsController;
  int _walkLengthValue = NotificationHandler().walkLength();
  int _noNotificationsValue = NotificationHandler().maxNotifications();
  //final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  //final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _currentAffectedByWeather;


  @override
  void initState() {
    super.initState();
    //_maxNotificationsController = TextEditingController(text: NotificationHandler().maxNotifications().toString());
    //_walkLengthController = TextEditingController(text: NotificationHandler().walkLength().toString());
    _currentAffectedByWeather = NotificationHandler().affectedByWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Inställningar"),
        ),
        backgroundColor: Colors.white,
        body: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.AppColors.brandPink[500],
                    Theme.AppColors.brandOrange[500]
                  ],
                )
            ),
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
                                        "Önskat antal notifikationer",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.all(Radius.circular(12)),
                                        ),
                                        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                                        child: NumberPicker(
                                          value: _noNotificationsValue,
                                          minValue: 0,
                                          maxValue: 3,
                                          axis: Axis.horizontal,
                                          onChanged: (value) => setState(() => _noNotificationsValue = value),
                                        ),
                                      )
                                    ]
                                ),
                                Column(
                                  children: <Widget>[
                                    Text(
                                        "Promenadlängd i minuter",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                    )
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(12)),
                                      ),
                                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                                      child: NumberPicker(
                                      value: _walkLengthValue,
                                      minValue: 20,
                                      maxValue: 120,
                                      step: 5,
                                      onChanged: (value) => setState(() => _walkLengthValue = value),
                                    ),
                                    )],
                                ),
                                Column(
                                  children: <Widget>[
                                    Text(
                                        "Låt väder påverka notifikationer",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        )
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      alignment: Alignment.center,
                                      /*decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(12)),
                                      ),*/
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
                                  child: Text("Spara"),
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

  void _saveActions() {
    try {
      int newMaxNotifications = _noNotificationsValue;
      int newWalkLength = _walkLengthValue;
      bool newAffectedByWeather = _currentAffectedByWeather;
      NotificationHandler().updateSettings(newMaxNotifications, newWalkLength, newAffectedByWeather);
      final snackBar = SnackBar(
        content: Text('Inställningar uppdaterade!')
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    catch(e) {
      print("There are 🐜🐜🐜 in the spooky setting screen");
      print(e);
    }
  }


}