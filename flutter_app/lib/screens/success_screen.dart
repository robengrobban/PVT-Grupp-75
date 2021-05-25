import 'dart:convert';
import 'dart:math';

import 'package:calendar_widget/calendar_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/Medal.dart';
import 'package:flutter_app/models/account_handler.dart';
import 'package:flutter_app/models/performed_route.dart';
import 'package:flutter_app/main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_app/theme.dart' as Theme;

class SuccessScreen extends StatefulWidget {
  SuccessScreen({Key key}) : super(key: key);

  @override
  State createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {


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

}

class StreakScreen extends StatefulWidget {
  State createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  Map<DateTime, List<PerformedRoute>> _performedRoutes = {};
  @override
  void initState() {
    super.initState();
    _getPerformedRoutes();
  }

  @override
  Widget build(BuildContext context) {
    CalendarHighlighter highlighter = (DateTime dt) {
      print(dt);
      // randomly generate a boolean list of length monthLength + 1 (because months start at 1)
      return List.generate(Calendar.monthLength(dt) + 1, (index) {
        return (_performedRoutes.containsKey(dt.add(Duration(days: index-1))));
      });
    };
    return Container(
        margin: EdgeInsets.only(top: 16),
        alignment: Alignment.topCenter,
        child: Calendar(
          highlighter: highlighter,
          width: MediaQuery.of(context).size.width - 32,
          onTapListener: (DateTime dt) {
            print(dt);
            print(_performedRoutes.containsKey(dt) );
            _performedRoutes.containsKey(dt) ? showDialog<String>(
                context: context,
                builder: (BuildContext context) =>
                    AlertDialog(
                      title: const Text('Your route'),
                      content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text(_performedRoutes[dt][0].distance.toString()),
                              Text('Distance:')
                            ],
                          )),
                    )

              //highlighter:highlighter,

            ) : null;
          }
        ));
  }
  Future<void> _getPerformedRoutes() async {
    // String token = await AccountHandler().accessToken();
    // var uri = USES_HTTPS ?  Uri.https(SERVER_HOST, '/performedRoutes', {"token": token}) : Uri.http(SERVER_HOST, '/performedRoutes', {"token":token});
    // print(uri.toString());
    // final response = await http.get(uri);
    //
    //   setState(() {
    //   if(response.statusCode == 200) {
    //     _performedRoutes = _parseRoute(response.body);
    //   } else {
    //     return {};
    //   }
    //   });

    setState(() {
      _performedRoutes = {DateTime(2021,05,29): [PerformedRoute(waypoints: [], startPoint: LatLng(58.34, 17.30000000000001), distance: 10, actualDuration: 0, timeFinished: DateTime(2021,05,29))], DateTime(2021,05,28): [PerformedRoute(waypoints: [], startPoint: LatLng(58.34, 17.30000000000001), distance: 10, actualDuration: 0, timeFinished:DateTime(2021,05,28,21,34,55))], DateTime(2021,05,26) : [PerformedRoute(waypoints: [], startPoint: LatLng(58.34, 17.30000000000001), distance: 10, actualDuration: 0, timeFinished: DateTime(2021,05,26,21,34,55,000))], DateTime(2021,05,25, 00,00,00): [PerformedRoute(waypoints: [], startPoint: LatLng(58.34, 17.30000000000001), distance: 10, actualDuration: 0, timeFinished: DateTime(2021,05,25,21,34,55))]};
    });
  }


  Map<DateTime, List<PerformedRoute>> _parseRoute(String responseBody) {
    Map<DateTime, List<PerformedRoute>> routeMap = {};
    List <dynamic> routes = jsonDecode(responseBody);
    for(var d in routes) {
      PerformedRoute route = PerformedRoute.fromJson(d);
      DateTime routeTime = route.timeFinished;
      DateTime routeDate = DateTime(routeTime.year,routeTime.month, routeTime.day);
      if(!routeMap.containsKey(routeDate)) {
        routeMap[routeDate] = [];
      }
      routeMap[routeDate].add(route);
      print(routeMap);
    }
    return routeMap;
  }
}
