import 'package:flutter/material.dart';
import 'package:flutter_app/util/date_helper.dart';
import 'package:flutter_app/models/performed_route.dart';
import 'package:flutter_app/models/user_route_handler.dart';
import 'package:flutter_app/theme.dart' as Theme;
import 'package:lottie/lottie.dart';

class WeeklySummaryScreen extends StatefulWidget {
  WeeklySummaryScreen({Key key}) : super(key: key);

  @override
  State createState() => _WeeklySummaryState();
}

class _WeeklySummaryState extends State<WeeklySummaryScreen> {
  int _numberOfWalks = 0;

  double _distance = 0;

  int _minutes = 0;
  
  int _hours = 0;



  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    List<PerformedRoute> performedRoutes = await UserRouteHandler().getRoutesBetween(DateTime.now().getBeginningOfWeek(), DateTime.now().getEndOfWeek());
    int totalTimeInMinutes = performedRoutes.fold(0, (previousValue, element) => previousValue + element.actualDuration) ~/60;
    int totalDistanceInMeters = performedRoutes.fold(0, (previousValue, element) => previousValue + element.distance);
    setState(() {
      _numberOfWalks = performedRoutes.length;
      _distance = totalDistanceInMeters / 1000;
      _hours = totalTimeInMinutes ~/60;
      _minutes = totalTimeInMinutes % 60;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Weekly Summary"),
        ),
        backgroundColor: Colors.white,
        body: Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(gradient: Theme.appGradiant,),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(padding: EdgeInsets.only(bottom:30), child:Text("This week you have:", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),)),
                    Padding(padding: EdgeInsets.only(bottom:20), child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.white,size: 40,),
                        Text("Made $_numberOfWalks walks",style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))
                      ],
                    )),
                Padding(padding: EdgeInsets.only(bottom:30), child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.white,size: 40,),
                    Text("Walked ${_distance.toStringAsFixed(2)} km",style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))
                  ],
                )),
                Padding(padding: EdgeInsets.only(bottom:30), child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.white,size: 40,),
                    Text("Walked for ${_hours>0 ? _hours.toString() + "hours and " : ""}$_minutes minutes",style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))
                  ],
                )),
                Padding(padding: EdgeInsets.only(bottom:30), child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.white,size: 40,),
                    Expanded(child:Text("And hopefully made a lot of people happy", softWrap: true, maxLines: 2,style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)))
                  ],
                )),
                Expanded(
                  child: Lottie.asset('assets/images/firework-animation.json'),
                ),
              ],
            )
        )
    );
  }

}