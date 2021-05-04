import 'package:flutter_app/models/notification_handler.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  @override
  State createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Hemsökta Notifikationer"),
        ),
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
                child: ElevatedButton(
                  child: Text("Generera notifikationer"),
                  onPressed: NotificationHandler().generateCalendarNotifications,
                )
            )
          ],
        )
    );
  }



}

