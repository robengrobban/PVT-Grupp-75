import 'dart:convert';
import 'dart:math';

import 'package:calendar_widget/calendar_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/Medal.dart';

import 'package:flutter_app/theme.dart' as Theme;

class SuccessScreen extends StatefulWidget {
  SuccessScreen({Key key}) : super(key: key);

  @override
  State createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(gradient: Theme.appGradiant),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text("Achievements"),
              bottom: TabBar(
                labelStyle:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 10,
                tabs: [
                  Tab(text: "Awards"),
                  Tab(text: "Streaks"),
                ],
              ),
            ),
            body: Container(
              decoration: BoxDecoration(gradient: Theme.appGradiant),
              padding: EdgeInsets.all(32),
              child: TabBarView(
                children: [
                  MedalScreen(),
                  StreakScreen(),
                  //Icon(Icons.directions_transit),
                ],
              ),
            )),
      ),
    );
  }
}

List<Medal> _getMedals() {
  return [
    new Medal(type: MedalType.THREE_DAY_STREAK),
    new Medal(type: MedalType.FIVE_DAY_STREAK),
    new Medal(type: MedalType.TEN_DAY_STREAK),
    new Medal(type: MedalType.FIFTEEN_DAY_STREAK),
    new Medal(type: MedalType.TWENTY_DAY_STREAK),
    new Medal(type: MedalType.THIRTY_DAY_STREAK),
    new Medal(type: MedalType.THREE_DAY_STREAK),
    new Medal(type: MedalType.THREE_DAY_STREAK),
    new Medal(type: MedalType.THREE_DAY_STREAK),
    new Medal(type: MedalType.THREE_DAY_STREAK),
    new Medal(type: MedalType.THREE_DAY_STREAK),
    new Medal(type: MedalType.THREE_DAY_STREAK),
    new Medal(type: MedalType.THREE_DAY_STREAK),
    new Medal(type: MedalType.THREE_DAY_STREAK),
    new Medal(type: MedalType.THREE_DAY_STREAK),
  ];
}

class MedalScreen extends StatefulWidget {
  State createState() => _MedalScreenState();
}

class _MedalScreenState extends State<MedalScreen> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
        crossAxisCount: 3,
        children: List.generate(_getMedals().length, (index) {
          return Center(
              child: ImageIcon(
            AssetImage('assets/images/141054.png'),
            size: 90,
            color: _getMedals()[index].type.color,
          ));
        }));
  }
}

class StreakScreen extends StatefulWidget {
  State createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  @override
  Widget build(BuildContext context) {
    CalendarHighlighter highlighter = (DateTime dt) {
      // randomly generate a boolean list of length monthLength + 1 (because months start at 1)
      return List.generate(Calendar.monthLength(dt) + 1, (index) {
        return (Random().nextDouble() < 0.3);
      });
    };
    return Container(
        margin: EdgeInsets.only(top: 16),
        alignment: Alignment.topCenter,
        child: Calendar(
          width: MediaQuery.of(context).size.width - 32,
          onTapListener: (DateTime dt) => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    title: const Text('Your route'),
                    content: SingleChildScrollView(
                        child: ListBody(
                      children: const <Widget>[
                        Text('Duration:'),
                        Text('Distance:')
                      ],
                    )),
                  )

              //highlighter:highlighter,

              ),
        ));
  }
}
