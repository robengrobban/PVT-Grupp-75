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

  TextEditingController _maxNotificationsController;
  TextEditingController _walkLengthController;
  int _value = NotificationHandler().walkLength();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _maxNotificationsController = TextEditingController(text: NotificationHandler().maxNotifications().toString());
    _walkLengthController = TextEditingController(text: NotificationHandler().walkLength().toString());
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
            padding: const EdgeInsets.all(32.0),
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
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.all(12),
                                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 1,
                                            )
                                        ),
                                        child: TextField(
                                            controller: _maxNotificationsController,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.digitsOnly
                                            ]
                                        ),
                                      )
                                    ]
                                ),
                                Column(
                                  children: <Widget>[
                                    SizedBox(height: 60,),
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
                                      value: _value,
                                      minValue: 10,
                                      maxValue: 100,
                                      onChanged: (value) => setState(() => _value = value),
                                    ),
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

  void _saveActions() {
    try {
      int newMaxNotifications = int.parse(_maxNotificationsController.text);
      int newWalkLength = _value;
      NotificationHandler().updateSettings(newMaxNotifications, newWalkLength);
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