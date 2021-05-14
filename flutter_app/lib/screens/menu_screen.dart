

import 'package:flutter/material.dart';
import 'package:flutter_app/models/account.dart';
import 'package:flutter_app/models/weather.dart';
import 'package:flutter_app/theme.dart' as Theme;
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
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.AppColors.brandPink[500],
                    Theme.AppColors.brandOrange[500]
                  ],
                ),
            ),
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
                          MenuItem(Icons.cloud_off, "DEBUG WEATHER", _itemPadding, () {
                            Weather weather = Weather();
                            weather.todaysWeather();
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
    print(Account().isLoggedIn().toString());
  }

  void _openAchievements() {
    print("Opening Achievements");
  }

  void _openWeeklySummary() {
    print("Opening Weekly Summary");
  }

  Widget _getAccountButton() {
    if ( Account().isLoggedIn() ) {
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
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Vill du logga ut?'),
          content: SingleChildScrollView(
            child: /*ListBody(
              children: <Widget>[
                Text('This is a demo alert dialog.'),
              ],
            ),*/null
          ),
          actions: <Widget>[
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ElevatedButton(
                  child: Text('Logga ut'),
                  onPressed: () {
                    Account().handleSignOut();
                    Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
                  },
                )
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextButton(
                child: Text('Stanna'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            )
          ],
        );
      },
    );
  }

}