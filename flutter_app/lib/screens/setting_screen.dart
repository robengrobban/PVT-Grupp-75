import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/models/notification_handler.dart';
import 'package:flutter_app/theme.dart' as Theme;

class SettingScreen extends StatefulWidget {
  @override
  State createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {

  TextEditingController _maxNotificationsController;
  TextEditingController _walkLengthController;
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
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextField(
                                      decoration: InputDecoration(
                                        labelText: "Antalet schemaläggda notifikationer",
                                        border: OutlineInputBorder()
                                      ),
                                      controller: _maxNotificationsController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly
                                      ]
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextField(
                                      decoration: InputDecoration(
                                          labelText: "Promenadlängd för notifikationer",
                                          border: OutlineInputBorder()
                                      ),
                                      controller: _walkLengthController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly
                                      ]
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: viewportConstraints.maxWidth,
                                    ),
                                    child: ElevatedButton(
                                      child: Text("Spara"),
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                                        foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                        shadowColor: MaterialStateProperty.all<Color>(Colors.transparent)
                                      ),
                                      onPressed: _saveActions,
                                    ),
                                  )
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
      int newWalkLength = int.parse(_walkLengthController.text);
      NotificationHandler().updatedSettings(newMaxNotifications, newWalkLength);
    }
    catch(e) {
      print("There are 🐜🐜🐜 in the spooky setting screen");
      print(e);
    }
  }


}