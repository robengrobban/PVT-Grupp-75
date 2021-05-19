import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/Route.dart';

import 'package:flutter_app/theme.dart' as Theme;
import 'package:shared_preferences/shared_preferences.dart';

class SuccessScreen extends StatefulWidget {
  SuccessScreen({Key key}) : super(key: key);

  @override
  State createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  int _medals = 5;
  int _currentStreak = 30;

  int _longestStreak = 100;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Success!!!"),
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    ElevatedButton(
                        child: Icon(
                          CupertinoIcons.star_fill,
                          size: 35,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          _showMedalDialog();
                        },
                        style: ButtonStyle(
                            elevation: MaterialStateProperty.all<double>(10),
                            shadowColor:
                                MaterialStateProperty.all<Color>(Colors.black),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.indigo[900]),
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                                CircleBorder()),
                            minimumSize:
                                MaterialStateProperty.all<Size>(Size(50, 50)))),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("You have $_medals medals!",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton(
                        child: Icon(
                          Icons.calendar_today,
                          size: 35,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                        style: ButtonStyle(
                            elevation: MaterialStateProperty.all<double>(10),
                            shadowColor:
                                MaterialStateProperty.all<Color>(Colors.black),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.indigo[900]),
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                                CircleBorder()),
                            minimumSize:
                                MaterialStateProperty.all<Size>(Size(50, 50)))),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                          "Your current streak is $_currentStreak days!",
                          maxLines: 5,
                          softWrap: true,
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton(
                        child: Icon(
                          Icons.directions_run,
                          size: 35,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                        style: ButtonStyle(
                            elevation: MaterialStateProperty.all<double>(10),
                            shadowColor:
                                MaterialStateProperty.all<Color>(Colors.black),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.indigo[900]),
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                                CircleBorder()),
                            minimumSize:
                                MaterialStateProperty.all<Size>(Size(50, 50)))),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                          "Your longest streak is $_longestStreak days!",
                          maxLines: 5,
                          softWrap: true,
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    )
                  ],
                )
              ],
            )));
  }

  Future<List<CircularRoute>> _getWalkedRoutes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var stringRoutes = prefs.getString("Routes");
    List<CircularRoute> routes = List.of({});
    if (stringRoutes != null) {
      for (var d in jsonDecode(stringRoutes)) {
        routes.add(CircularRoute.fromJson(d));
      }
    }
    return routes;
  }

  Future<void> _showMedalDialog() async {
    List<CircularRoute> routes = await _getWalkedRoutes();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
                title: Text("Medals Won"),
                backgroundColor: Theme.AppColors.brandOrange[500],
                content: Container(
                  height: 400,
                  width: 400,
                  child: ShaderMask(
                      shaderCallback: (Rect rect) {
                        return LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white,
                            Colors.transparent,
                          ],
                          stops: [
                            0.9,
                            1.0
                          ], // 10% purple, 80% transparent, 10% purple
                        ).createShader(rect);
                      },
                      child: ListView.builder(
                          clipBehavior: Clip.antiAlias,
                          itemCount: routes.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: CustomListItem(
                                date: DateTime.now(),
                                duration: routes[index].duration,
                                distance: routes[index].distance,
                                thumbnail: Image(
                                  image: NetworkImage(
                                      'https://images.theconversation.com/files/387712/original/file-20210304-15-n1wg4d.jpg?ixlib=rb-1.1.0&rect=133%2C110%2C3701%2C2473&q=45&auto=format&w=496&fit=clip'),
                                ),
                                title: routes[index].southWestBound.toString(),
                              ),
                            );
                          })),
                ));
          });
        });
  }
}

class CustomListItem extends StatelessWidget {
  const CustomListItem({
    @required this.thumbnail,
    @required this.title,
    @required this.date,
    @required this.distance,
    @required this.duration,
    @required this.id,
  }) : super();

  final Widget thumbnail;
  final String title;
  final DateTime date;
  final int distance;
  final int duration;
  final int id;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Padding(
                padding: EdgeInsets.only(left: 5, top: 2), child: thumbnail),
          ),
          Expanded(
            flex: 3,
            child: _VideoDescription(
              title: title,
              date: date,
              distance: distance,
              duration: duration,
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoDescription extends StatelessWidget {
  const _VideoDescription({
    @required this.title,
    @required this.date,
    @required this.distance,
    @required this.duration,
  }) : super();

  final String title;
  final DateTime date;
  final int distance;
  final int duration;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14.0,
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
          Text(
            date.toString(),
            style: const TextStyle(fontSize: 10.0),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
          Text(
            '$distance meter',
            style: const TextStyle(fontSize: 10.0),
          ),
          Text(
            '$duration min',
            style: const TextStyle(fontSize: 10.0),
          ),
        ],
      ),
    );
  }
}
