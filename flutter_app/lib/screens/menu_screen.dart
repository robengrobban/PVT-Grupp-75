

import 'package:flutter/material.dart';
import 'package:flutter_app/models/account_handler.dart';
import 'package:flutter_app/models/location_handler.dart';
import 'package:flutter_app/models/notification_handler.dart';
import 'package:flutter_app/models/weather_handler.dart';
import 'package:flutter_app/theme.dart' as Theme;
import 'package:flutter_app/widgets/alert_text_button.dart';
import 'package:flutter_app/widgets/menu_item.dart';

class MenuScreen extends StatefulWidget {
  @override
  State createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {

  final EdgeInsets _itemPadding = const EdgeInsets.symmetric(vertical: 10, horizontal: 0);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Meny"),
          actions: [
            IconButton(
                icon: Icon(Icons.settings),
                onPressed: _openSettings
            )
          ],
        ),
        backgroundColor: Colors.white,
        body: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(gradient: Theme.appGradiant,),
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints viewportConstraints) {
                  return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: viewportConstraints.maxHeight,
                        ),
                        child: Container(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                MenuItem(Icons.person, "Profil", _itemPadding, _openProfile),
                                MenuItem(Icons.military_tech, "Framsteg", _itemPadding, _openAchievements),
                                MenuItem(Icons.analytics, "Veckosummering", _itemPadding, _openWeeklySummary),
                                _getAccountButton(),
                                MenuItem(Icons.notifications, "DEBUG NOTIFICATION", _itemPadding, () {
                                  Navigator.of(context).pushNamed("/debug-noti");
                                }),
                                MenuItem(Icons.cloud_off, "DEBUG WEATHER", _itemPadding, () async {
                                  WeatherHandler().todaysWeather( await LocationHandler().latlon() );
                                  WeatherHandler().currentWeather( await LocationHandler().latlon() ).then((value) {
                                    print("Temperature");
                                    print(value.temperature());
                                  });
                                }),
                                MenuItem(Icons.construction, "DEBUG FORCE REBUILD", _itemPadding, () {
                                  Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
                                })
                              ],
                            )
                        ),
                      )
                  );
                }
            )
        )
    );
  }

  void _openProfile() {
    print(AccountHandler().isLoggedIn().toString());
    print(AccountHandler().id().toString());
    AccountHandler().accessToken().then((value) => print(value));
  }

  void _openAchievements() {
    Navigator.of(context).pushNamed("/success");
    print("Opening Achievements");
  }

  void _openWeeklySummary() {
    print("Opening Weekly Summary");
  }

  Widget _getAccountButton() {
    if ( AccountHandler().isLoggedIn() ) {
      return MenuItem(Icons.logout, "Logga ut", _itemPadding, _getOUT);
    }
    return MenuItem(Icons.logout, "Logga in", _itemPadding, _getIN);
  }

  void _getOUT() {
    _showLogoutAlert();
  }

  void _getIN() {
    Navigator.of(context).pushNamed("/login");
  }

  void _openSettings() {
    Navigator.of(context).pushNamed("/settings");
  }

  Future<void> _showLogoutAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must'nt tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Vill du logga ut?'),
          content: SingleChildScrollView(
              child: null
          ),
          actions: <Widget>[
            AlertTextButton('Logga ut', () {
              AccountHandler().handleSignOut();
              Navigator.of(context).popUntil(ModalRoute.withName('/home'));
            },
              true,
            ),
            AlertTextButton('Stanna', () => Navigator.of(context).pop(), false),
          ],
        );
      },
    );
  }

}