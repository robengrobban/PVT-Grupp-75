import 'package:calendar_widget/calendar_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/Medal.dart';
import 'package:flutter_app/models/Streak.dart';
import 'package:flutter_app/models/medal_handler.dart';
import 'package:flutter_app/models/medal_repository.dart';
import 'package:flutter_app/models/performed_route.dart';
import 'package:flutter_app/models/user_route_handler.dart';
import 'package:flutter_app/widgets/big_gradient_dialog.dart';

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
              padding: EdgeInsets.all(15),
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
  List<Medal> _medals = [];
  @override
  void initState() {
    super.initState();
    _getMedals();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
        crossAxisCount: 3,
        children: List.generate(
          _medals.length,
          (index) {
            return Column(children: [
              Center(
                child: ShaderMask(
                  child: ImageIcon(
                    AssetImage('assets/images/141054.png'),
                    size: 90,
                    color: MedalRepository()
                        .getColor(_medals[index].type, _medals[index].value),
                  ),
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [
                        Colors.transparent,
                        MedalRepository()
                            .getColor(_medals[index].type, _medals[index].value)
                      ],
                      stops: [0.0, 0.5],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcIn,
                ),
              ),
              SizedBox(
                width: 90,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(MedalRepository().getDescription(
                      _medals[index].type, _medals[index].value)),
                ),
              )
            ]);
          },
        ));
  }

  Future<void> _getMedals() async {
    List<Medal> _userMedals = await MedalHandler().getMedals();
    setState(() {
      _medals = _userMedals;
    });
  }
}

class StreakScreen extends StatefulWidget {
  State createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  Map<DateTime, List<PerformedRoute>> _performedRoutes = {};

  Streak _longestStreak;

  Streak _currentStreak;

  @override
  void initState() {
    super.initState();
    _getPerformedRoutes();
    _getLongestStreak();
    _getCurrentStreak();
  }

  @override
  Widget build(BuildContext context) {
    CalendarHighlighter highlighter = (DateTime dt) {
      print(dt);
      // randomly generate a boolean list of length monthLength + 1 (because months start at 1)
      return List.generate(Calendar.monthLength(dt) + 1, (index) {
        return (_performedRoutes
            .containsKey(dt.add(Duration(days: index - 1))));
      });
    };
    return Container(
        margin: EdgeInsets.only(top: 16),
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Calendar(
                highlighter: highlighter,
                width: MediaQuery.of(context).size.width - 32,
                onTapListener: (DateTime dt) {
                  if (_performedRoutes.containsKey(dt))
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => BigGradientDialogShell(
                        showArrow: false,
                        title: 'Your routes ${dt.day}/${dt.month}',
                        titleSize: 20,
                        child: Container(
                          width: 200,
                          height: 200,
                          child: ListView(
                            children: List.generate(_performedRoutes[dt].length,
                                (index) {
                              return Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0,
                                        bottom: 8,
                                        left: 12,
                                        right: 12),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              "${(_performedRoutes[dt][index].timeFinished.hour)}:${(_performedRoutes[dt][index].timeFinished.minute)}",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.AppColors
                                                      .brandOrange[500])),
                                          Row(
                                            children: [
                                              Text(
                                                "Distance: ",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text((_performedRoutes[dt][index]
                                                              .distance /
                                                          1000)
                                                      .toStringAsFixed(2) +
                                                  " km")
                                            ],
                                          ),
                                          Row(children: [
                                            Text("Duration: ",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text((_performedRoutes[dt][index]
                                                            .actualDuration ~/
                                                        60)
                                                    .toString() +
                                                " min")
                                          ])
                                        ]),
                                  ));
                            }),
                          ),
                        ),
                      ),
                    );
                }),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      ImageIcon(
                        AssetImage('assets/images/1372969.png'),
                        size: 40,
                        color: Colors.red,
                      ),
                      Text("Longest Streak ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_longestStreak == null
                          ? "?"
                          : _longestStreak.days.toString() + " days")
                    ],
                  ),
                  Column(
                    children: [
                      ImageIcon(
                        AssetImage('assets/images/crown-clip-art-20.png'),
                        size: 40,
                        color: Colors.yellowAccent,
                      ),
                      Text("Current Streak ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_currentStreak == null
                          ? "?"
                          : _currentStreak.days.toString() + " days")
                    ],
                  ),
                ],
              ),
            )
          ],
        ));
  }

  Future<void> _getLongestStreak() async {
    await UserRouteHandler().getLongestStreak().then((streak) {
      setState(() {
        _longestStreak = streak;
      });
    });
  }

  Future<void> _getCurrentStreak() async {
    await UserRouteHandler().getCurrentStreak().then((streak) {
      setState(() {
        _currentStreak = streak;
      });
    });
  }

  Future<void> _getPerformedRoutes() async {
    await UserRouteHandler().getRoutesAsDateMap().then((performedroutes) {
      setState(() {
        _performedRoutes = performedroutes;
      });
    });
  }
}
