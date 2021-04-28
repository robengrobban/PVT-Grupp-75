
import 'package:flutter/material.dart';
import 'package:flutter_app/models/account.dart';


class LoginScreen extends StatefulWidget {
  @override
  State createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {

  @override
  void initState() {
    super.initState();
    setState(() {
      Account().update(state: this);
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
            ),
            Text(Account().displayName())
          ],
        )
    );
  }



}
