import 'package:flutter_app/models/event.dart';
import 'package:flutter_app/models/account.dart';
import "package:flutter_app/models/notification_spot.dart";
import 'package:flutter_app/models/weather.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Singleton class for handling all of the apps notifications.
class NotificationHandler {

  /// Define private constructor
  NotificationHandler._privateConstructor();

  /// The NotificationHandler Instance
  static final NotificationHandler _instance = NotificationHandler._privateConstructor();

  /// Load notification plugin.
  FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  /// The number of notifications left that can be scheduled.
  int _notificationsLeft;
  /// The length of walks.
  int _walkLength;
  final int _defaultWalkLength = 20;
  /// The time required for a spot in the calendar to candidate for a notification.
  int _timeRequired;
  final int _defaultOffset = 10;

  SharedPreferences _preferences;

  Weather _weather = Weather();

  /// The maximum number of scheduled notifications.
  int _maxNotifications;
  final int _defaultMaxNotifications = 2;

  /// Factory constructor to facilitate the Singleton design principle.
  factory NotificationHandler() {
    return _instance;
  }

  /// Initialising the NotificationHandler object.
  void init() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings("@drawable/new_more_and_better_improved_logo");
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    _notifications.initialize(initializationSettings);
    tz.initializeTimeZones();

    List<PendingNotificationRequest> pending;
    await _fetchNotifications().then((value) => pending = value);

    _preferences = await SharedPreferences.getInstance();
    _loadNotificationSettings();

    _notificationsLeft = _maxNotifications - pending.length;
    _timeRequired = _walkLength + _defaultOffset;

    print(_maxNotifications);
    print(_walkLength);
    print(_notificationsLeft);
  }

  void _saveNotificationSettings() {

    _preferences.setInt("maxNotifications", _maxNotifications);
    _preferences.setInt("walkLength", _walkLength);

  }

  void _loadNotificationSettings() {

    _maxNotifications = _preferences.getInt("maxNotifications") ?? _defaultMaxNotifications;
    _walkLength = _preferences.getInt("walkLength") ?? _defaultWalkLength;

  }

  void updatedSettings(int maxNotifications, int walkLength) {
    _maxNotifications = maxNotifications;
    _walkLength = walkLength;
    _timeRequired = _walkLength + _defaultOffset;
    _saveNotificationSettings();
    wipeNotifications();
    generateCalendarNotifications();
  }

  int walkLength() {
    return _walkLength;
  }
  int maxNotifications() {
    return _maxNotifications;
  }

  /// Remove all scheduled notifications.
  Future<void> wipeNotifications() async {
    _notificationsLeft = _maxNotifications;
    await _notifications.cancelAll();
  }

  /// Retrieve all events from the currently logged in account.
  Future<List<Event>> _fetchEvents() async {
    return await Account().events();
  }

  /// Retrieve all scheduled notifications.
  Future<List<PendingNotificationRequest>> _fetchNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Show all currently scheduled notifications (DEBUG).
  void showNotifications() async {
    List<PendingNotificationRequest> pending = await _fetchNotifications();
    print("Notifications:");
    print("Left: " + _notificationsLeft.toString());
    for (PendingNotificationRequest p in pending) {
      print(p.id);
      print(p.body);
    }
  }

  /// Generate notifications to be scheduled.
  Future<void> generateCalendarNotifications() async {

    print("Should generate?");
    if ( _notificationsLeft == 0 || !Account().isLoggedIn() ) {
      print("No");
      return;
    }
    print("Yes");

    List<Event> events = await _fetchEvents();
    List<PendingNotificationRequest> pending = await _fetchNotifications();
    List<NotificationSpot> spots = _generateNotificationSpots(events);

    for ( NotificationSpot spot in spots ) {
      if ( _notificationsLeft == 0 ) {
        break;
      }
      if ( spot.durationInMinutes() < _timeRequired ) {
        continue;
      }

      int id = spot.id();
      String title = "Det finns en möjlig promenad 🐜 🐜 🐜";
      String message = spot.startTime().toString();

      tz.TZDateTime time = tz.TZDateTime.from( spot.startTime(), tz.local );

      _schedule(id, title, message, time);
      bool conflict = false;

      for ( PendingNotificationRequest request in pending ) {
        if ( request.id == id ) {
          conflict = true;
          break;
        }
      }

      if ( !conflict ) {
        _notificationsLeft--;
      }

      print(spot.id());
      print(spot.startTime());

    }

  }

  /// Generate spots for notifications.
  /// Uses a list of events to generate them
  List<NotificationSpot> _generateNotificationSpots(List<Event> events) {
    List<NotificationSpot> spots = List.empty(growable: true);
    if ( events.length >= 2 ) {
      for (int i = 0; i < events.length-1; i++) {

        DateTime startTime = events[i].endTime();
        DateTime endTime = events[i+1].startTime();
        int id = events[i].id().hashCode;

        spots.add(new NotificationSpot(id, startTime, endTime));

      }
    }
    return spots;
  }

  /// Schedule a notification.
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

  /// Send a notification, instantly
  void _send(int id, String title, String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'WalkInProgress', 'Calendar Notifications', 'Notifications for walking opportunities.',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false);

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notifications.show(id, title, message, platformChannelSpecifics, payload: '');
  }


 


}

