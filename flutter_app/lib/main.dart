import 'package:flutter/material.dart';
import 'package:flutter_app/models/location_handler.dart';
import 'package:flutter_app/screens/menu_screen.dart';
import 'package:flutter_app/screens/notification_screen.dart';
import 'package:flutter_app/screens/settings_screen.dart';
import 'package:flutter_app/screens/success_screen.dart';
import 'models/account_handler.dart';
import 'screens/camera_previews_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/login_screen.dart';
import 'package:flutter_app/models/notification_handler.dart';
import 'package:flutter_app/screens/home_screen.dart';
import 'theme.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:flutter_app/theme.dart' as Theme;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AccountHandler().init();
  await LocationHandler().init();
  await NotificationHandler().init();
  runApp(WalkInProgressApp());
}

class WalkInProgressApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GlobalLoaderOverlay(
      child: MaterialApp(
        title: 'Walk in Progress',
        theme: walkInProgressThemeData,
        initialRoute: '/home',
        routes: {
          '/home': (context) => HomeScreen(payload: NotificationHandler().payload() ?? ""),
          '/login': (context) => LoginScreen(),
          '/menu': (context) => MenuScreen(),
          '/settings': (context) => SettingScreen(),
          '/debug-noti': (context) => NotificationScreen(),
          '/success': (context) => SuccessScreen(),
          '/camera': (context) => CameraScreen(),
          '/camera-previews': (context) => PreviewScreen(),
        }
      ),
      overlayOpacity: 0.5,
      overlayColor: Theme.AppColors.brandOrange[900],
    );
  }
}
