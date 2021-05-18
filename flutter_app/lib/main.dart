import 'package:flutter/material.dart';
import 'package:flutter_app/models/location_handler.dart';
import 'package:flutter_app/screens/menu_screen.dart';
import 'package:flutter_app/screens/notification_screen.dart';
import 'package:flutter_app/screens/setting_screen.dart';
import 'models/account_handler.dart';
import 'models/account.dart';
import 'screens/camera_previews_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/login_screen.dart';
import 'package:flutter_app/models/notification_handler.dart';
import 'package:flutter_app/screens/home_screen.dart';
import 'theme.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:flutter_app/theme.dart' as Theme;
import 'package:custom_loading_indicator/custom_loading_indicator.dart';

void main() {
  runApp(WalkInProgressApp());
  AccountHandler().init();
  NotificationHandler().init();
  LocationHandler().init();
}

class WalkInProgressApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GlobalLoaderOverlay(
      child: MaterialApp(
        title: 'Walk in Progress',
        theme: WalkInProgressThemeData,
        initialRoute: '/home',
        routes: {
          '/home': (context) => HomeScreen(),
          '/login': (context) => LoginScreen(),
          '/menu': (context) => MenuScreen(),
          '/settings': (context) => SettingScreen(),
          '/debug-noti': (context) => NotificationScreen(),
          '/camera': (context) => CameraScreen(),
          '/camera-previews': (context) => PreviewScreen(),
        },
      ),
      overlayOpacity: 0.8,
    );
  }
}
/*

Brand color 1 (0xffff6a83),
Brand color 2 (0xfff3a866)

 */
