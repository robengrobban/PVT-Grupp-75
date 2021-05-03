import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings("@drawable/new_more_and_better_improved_logo");
final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

class NotificationHandler {

  NotificationHandler._privateConstructor();

  static final NotificationHandler _instance = NotificationHandler._privateConstructor();

  int _count = 0;

  factory NotificationHandler() {
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    return _instance;
  }

  Future<void> send() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false);

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
        _count++, 'Knack Knack', 'Det finns en hemsökt prommenad för dig att gååååååååå', platformChannelSpecifics,
        payload: 'item x');
  }



}

