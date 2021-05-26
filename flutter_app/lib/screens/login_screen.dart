import 'package:flutter/material.dart';
import 'package:flutter_app/models/account_handler.dart';
import 'package:flutter_app/screens/%F0%9F%90%9C.dart';
import 'package:flutter_app/theme.dart' as Theme;

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  @override
  State createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  @override
  void initState() {
    super.initState();
    AccountHandler().onOneTimeUserChange(() {
      if ( AccountHandler().isLoggedIn() ) {
        //Navigator.of(context).pushReplacementNamed("/home");
        Navigator.of(context).popUntil(ModalRoute.withName('/home'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Log in"),
        ),
        backgroundColor: Colors.white,
        body: Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(gradient: Theme.appGradiant,),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  child: Image.asset("assets/img/new_improved_logo_with_more_style.png")                                                                                                                                          ,onLongPress: () {Navigator.of(context).push(MaterialPageRoute(builder: (context) => LeaveThisFile()));},
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.black)
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.login),
                        Text("Sign in with Google")
                      ],
                    ),
                  ),
                  onPressed: () async {
                    await AccountHandler().handleSignIn();
                  },
                )
              ],
            )
        )
    );
  }

}