import 'package:flutter/material.dart';
import 'package:flutter_app/models/account.dart';
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
    Account().update( callback: () {
      if ( Account().isLoggedIn() ) {
        Navigator.of(context).pushReplacementNamed("/home");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: Padding(
            padding: EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/img/🐜.png',
              fit:BoxFit.contain,
            ),
          ),
          title: Text("Walk in Progress"),
        ),
        backgroundColor: Colors.white,
        body: Container(
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                        Text("Logga in med Google")
                      ],
                    ),
                  ),
                  onPressed: () async {
                    await Account().handleSignIn();
                  },
                )
              ],
            )
        )
    );
  }

}
/*Center(
                child: Text(Account().displayName())
            ),
            FutureBuilder<List<Event>>(
              future: Account().events(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      padding: const EdgeInsets.all(8),
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container (
                            color: Colors.cyan,
                            child: ListTile(
                                title: Text("${snapshot.data[index].summary()}"),
                                subtitle: Text("${snapshot.data[index].startTime()} - ${snapshot.data[index].endTime()}")
                            )
                        );
                      }
                  );
                }
                else if ( snapshot.hasError ) {
                  return Center( child: Text("kan inte ladda kalendar", style: TextStyle(fontStyle: FontStyle.italic),) );
                }
                else {
                  return Center( child: Text("Laddar kalendar"));
                }
              },
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
            )*/
