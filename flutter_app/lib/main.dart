import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'package:flutter_app/models/account.dart';
import 'package:flutter_app/models/notification_handler.dart';
import 'package:flutter_app/screens/home_screen.dart';
import 'theme.dart';

void main() {
  runApp(WalkInProgressApp());

  NotificationHandler().init();
}

class WalkInProgressApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Walk in Progress',
      theme: WalkInProgressThemeData,
      home: LoginScreen()
    );
  }
}
/*

Brand color 1 (0xffff6a83),
Brand color 2 (0xfff3a866)

 */
