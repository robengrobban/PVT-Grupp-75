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
            ),
            Center(
                child: ElevatedButton(
                  child: Text("Ta bort alla notifikationer"),
                  onPressed: NotificationHandler().wipeNotifications,
                )
            ),
            Center(
                child: ElevatedButton(
                  child: Text("Visa alla notifikationer"),
                  onPressed: NotificationHandler().showNotifications,
                )
            ),
            Center(
                child: ElevatedButton(
                  child: Text("Skicka test notifikation"),
                  onPressed: () {
                    NotificationHandler().send(120, "TITEL", "MEDDELANDE");
                  },
                )
            ),
            Center(
                child: ElevatedButton(
                  child: Text("Visa inställningar"),
                  onPressed: () {
                    print("Max: " + NotificationHandler().maxNotifications().toString());
                    print("Walk length: " + NotificationHandler().walkLength().toString());
                    print("Affected by weather: " + NotificationHandler().affectedByWeather().toString());
                  },
                )
            )
          ],
        )
    );
  }



}

