import 'package:flutter_app/models/event.dart';
import 'package:flutter_app/models/account.dart';
import "package:flutter_app/models/notification_spot.dart";
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationHandler {

  NotificationHandler._privateConstructor();

  static final NotificationHandler _instance = NotificationHandler._privateConstructor();

  FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  int _notificationsLeft;
  int _walkLength;
  int _timeRequired;

  bool _walksGenerated = false;

  List<Event> _events = List.empty(growable: true);
  List<NotificationSpot> _spots = List.empty(growable: true);

  factory NotificationHandler() {
    return _instance;
  }

  void init() {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings("@drawable/new_more_and_better_improved_logo");
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    _notifications.initialize(initializationSettings);
    tz.initializeTimeZones();

    _notificationsLeft = 2;
    _walkLength = 20;
    _timeRequired = _walkLength + 10;
  }

  void wipeNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> _fetchEvents() async {
    await Account().events().then((value) => _events = value);
  }

  Future<void> generateCalendarNotifications() async {

    if ( _walksGenerated ) {
      return;
    }
    _walksGenerated = true;

    await _fetchEvents();
    _spots = List.empty(growable: true);

    if ( _events.length > 2 ) {
      for (int i = 0; i < _events.length-1; i++) {

        DateTime startTime = _events[i].endTime();
        DateTime endTime = _events[i+1].startTime();
        int id = _events[i].id().hashCode;

        _spots.add(new NotificationSpot(id, startTime, endTime));

      }
    }

    for ( NotificationSpot spot in _spots ) {
      if ( _notificationsLeft == 0 ) {
        break;
      }
      if ( spot.durationInMinutes() < _timeRequired ) {
        continue;
      }

      int id = spot.id();
      String title = "Det finns en möjlig promenad";
      String message = spot.startTime().toString();

      tz.TZDateTime time = tz.TZDateTime.from( spot.startTime(), tz.local );

      _schedule(id, title, message, time);
      _notificationsLeft--;

      print(spot.id());
      print(spot.startTime());

    }

  }

  void _schedule(int id, String title, String message, tz.TZDateTime time) async {
    await _notifications.zonedSchedule(
        id,
        title,
        message,
        time,
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'WalkInProgress',
                'Calendar Notifications',
                'Notifications for walking opportunities.',
                priority: Priority.high,
                importance: Importance.high,
                fullScreenIntent: true)),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
  }

  void send(int id, String title, String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'WalkInProgress', 'Calendar Notifications', 'Notifications for walking opportunities.',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false);

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notifications.show(id, title, message, platformChannelSpecifics, payload: '');
  }


 


}

