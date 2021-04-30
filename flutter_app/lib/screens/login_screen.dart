
import 'package:flutter/material.dart';
import 'package:flutter_app/models/account.dart';
import 'package:flutter_app/models/event.dart';


class LoginScreen extends StatefulWidget {
  @override
  State createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {

  List<Event> events = List.empty(growable: true);
  
  @override
  void initState() {
    super.initState();
    setState(() {
      Account().update(state: this);
      Account().generateCalendar();
      events = Account().events();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Hemsökt inloggningsskärm"),
        ),
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            Center(
                child: Text(Account().displayName())
            ),
            SingleChildScrollView(
              physics: ScrollPhysics(),
              child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: events.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container (
                      color: Colors.cyan,
                      child: ListTile(
                          title: Text("${events[index].summary()}"),
                          subtitle: Text("${events[index].startTime().toUtc()} - ${events[index].endTime().toUtc()}")
                      )
                    );
                  }
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  child: Text("Logga in"),
                  onPressed: () {
                    Account().handleSignIn();
                  },
                ),
                TextButton(
                  child: Text("Logga ut"),
                  onPressed: () {
                    Account().handleSignOut();
                  },
                )
              ],
            )
          ],
        )
    );
  }



}
