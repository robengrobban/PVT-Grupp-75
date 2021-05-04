import 'package:flutter/material.dart';
import 'package:flutter_app/models/account.dart';
import 'package:flutter_app/models/event.dart';


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
            Center(
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
            )
          ],
        )
    );
  }



}
