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

  final int _maxNotifications = 2;

  List<Event> _events = List.empty(growable: true);

  factory NotificationHandler() {
    return _instance;
  }

  void init() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings("@drawable/new_more_and_better_improved_logo");
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    _notifications.initialize(initializationSettings);
    tz.initializeTimeZones();

    List<PendingNotificationRequest> pending;
    await _fetchNotifications().then((value) => pending = value);

    _notificationsLeft = _maxNotifications - pending.length;
    _walkLength = 20;
    _timeRequired = _walkLength + 10;
  }

  Future<void> wipeNotifications() async {
    _notificationsLeft = _maxNotifications;
    await _notifications.cancelAll();
  }

  Future<void> _fetchEvents() async {
    await Account().events().then((value) => _events = value);
  }

  Future<List<PendingNotificationRequest>> _fetchNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  void showNotifications() async {
    List<PendingNotificationRequest> pending = await _notifications.pendingNotificationRequests();
    print("Notifications:");
    for (PendingNotificationRequest p in pending) {
      print(p.id);
      print(p.body);
    }
  }

  Future<void> generateCalendarNotifications() async {

    print("Should generate?");
    if ( _notificationsLeft == 0 || !Account().isLoggedIn() ) {
      print("No");
      return;
    }
    print("Yes");

    await _fetchEvents();
    List<NotificationSpot> spots = List.empty(growable: true);

    if ( _events.length >= 2 ) {
      for (int i = 0; i < _events.length-1; i++) {

        DateTime startTime = _events[i].endTime();
        DateTime endTime = _events[i+1].startTime();
        int id = _events[i].id().hashCode;

        spots.add(new NotificationSpot(id, startTime, endTime));

      }
    }

    for ( NotificationSpot spot in spots ) {
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

