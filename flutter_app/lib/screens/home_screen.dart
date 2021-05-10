import 'package:flutter/material.dart';
import 'package:flutter_app/screens/login_screen.dart';
import 'package:flutter_app/theme.dart' as Theme;

class HomeScreen extends StatefulWidget {
  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          /*leading: Padding(
            padding: EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/img/new_improved_logo_with_more_style.png',
              fit:BoxFit.contain,
            ),
          ),*/
          title: Text("Walk in Progress"),
        ),
        backgroundColor: Colors.white,
        body: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.AppColors.brandPink[500],
                    Theme.AppColors.brandOrange[500]
                  ],
                )),
            child: ElevatedButton(
              child: Text("Demo - tillbaka"),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
              },
            ),
        )
    );
  }




}