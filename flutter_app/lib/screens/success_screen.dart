import 'dart:convert';

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
    return  Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(gradient: Theme.appGradiant),
      child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true, title: Text("Achievements"),
              bottom: TabBar(
                labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 10,
              tabs: [
                Tab(text:"Medals"),
                Tab(text:"Streaks"),

              ],
              ),
            ),
            body: Container(
              decoration: BoxDecoration(gradient: Theme.appGradiant),
              padding: EdgeInsets.all(32),
              child:TabBarView(
              children: [
                MedalScreen(),
                Icon(Icons.directions_transit),

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
      new Medal(type: MedalType.THREE_DAY_STREAK),
      new Medal(type: MedalType.THREE_DAY_STREAK),
      new Medal(type: MedalType.THREE_DAY_STREAK),
      new Medal(type: MedalType.THREE_DAY_STREAK),
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

class _MedalScreenState extends State<MedalScreen>{
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(_getMedals().length, (index) {
        return Center(
            child: Icon(Icons.local_police, color: _getMedals()[index].type.color,)
        );
      }
      )
    );
  }
}

