
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/performed_route.dart';
import 'package:flutter_app/models/user_route_handler.dart';
import 'package:flutter_app/util/date_helper.dart';

import 'Streak.dart';

class MedalRepository {
  static final MedalRepository _repository = MedalRepository._internal();

  factory MedalRepository() => _repository;

  MedalRepository._internal();
  static final Map<MedalType, Map<int,_MedalInfo>> medals = {
    //Keep them in order from high to low
    MedalType.STREAK: {
      30 : _MedalInfo(Colors.deepOrange.shade900.withOpacity(0.9), "30 day streak"),
      20 : _MedalInfo(Colors.brown.shade900.withOpacity(0.9), "20 day streak"),
      15 : _MedalInfo(Colors.grey.shade600.withOpacity(0.9), "15 day streak"),
      10 : _MedalInfo(Colors.yellow.shade400.withOpacity(0.9), "10 day streak"),
      5 : _MedalInfo(myColor.shade300.withOpacity(0.9), "5 day streak"),
      3 : _MedalInfo(Colors.orange.shade900.withOpacity(0.9), "3 day streak"),
    },
    MedalType.WALKS_ONE_DAY : {
      5 : _MedalInfo(Colors.purple[600].withOpacity(0.9), "5 walks in a day"),
      3 : _MedalInfo(Colors.purpleAccent.withOpacity(0.9), "3 walks in a day"),
    },
    MedalType.KM_TOTAL : {
      100 : _MedalInfo(Colors.green[600].withOpacity(0.9), "100 km walked"),
      75 : _MedalInfo(Colors.teal[900].withOpacity(0.9), "75 km walked"),
      50 : _MedalInfo(Colors.lightGreen[800].withOpacity(0.9), "50 km walked"),
    }
  };

  Color getColor(MedalType type, int value) {
    return medals[type][value].color;
  }

  String getDescription(MedalType type, int value) {
    return medals[type][value].description;
  }
}

class _MedalInfo {
  final Color color;
  final description;

  _MedalInfo(this.color, this.description);
}

enum MedalType {
  STREAK,WALKS_ONE_DAY,KM_TOTAL
}

extension EvaluationValue on MedalType {
  Future<int> evaluate(PerformedRoute route) async {
    switch (this) {
      case MedalType.STREAK:
        Streak currentStreak = await UserRouteHandler().getCurrentStreak();
        if(currentStreak.endDate == DateTime.now().getBeginningOfDay()) {
          //If we have already been rewarded for a streak today we should not get a new achievement,
          // if we have had a walk today but haven't gotten an achievement, there is no chance of us getting one now
          return null;
        }
          return _evaluate(currentStreak.days, 1);

      case MedalType.WALKS_ONE_DAY:
        List<PerformedRoute> todaysRoutes = await UserRouteHandler().getRoutesBetween(DateTime.now().getBeginningOfDay(), DateTime.now().getEndOfDay());
        return _evaluate(todaysRoutes.length, 1);

      case MedalType.KM_TOTAL:
        int totalDistance = await UserRouteHandler().getTotalDistanceWalked();
        return _evaluate(totalDistance~/1000, route.distance~/1000);

      default:
        return null;
    }
  }

  int _evaluate(int oldValue, int valueToAdd) {
    for(int medalValue in MedalRepository.medals[this].keys) {
      print("medalvalue: $medalValue oldValue: $oldValue toAdd: $valueToAdd");
      if (oldValue < medalValue) {
        //This achievement hasn't been reached before
        if (oldValue + valueToAdd >= medalValue) {
         //and is now reached, Congrats!
          return medalValue;
        } else {
          //keep looking
        }
      } else {
        //this achievement has already been achieved
        //and all smaller achievements under it should also have been achieved so no meaning in looking further
        return null;
      }
    }
    return null;
  }
}

MaterialColor myColor = MaterialColor(0xFF880E4F, color);

Map<int, Color> color = {
  50: Color.fromRGBO(4, 131, 184, .1),
  100: Color.fromRGBO(4, 131, 184, .2),
  200: Color.fromRGBO(4, 131, 184, .3),
  300: Color.fromRGBO(4, 131, 184, .4),
  400: Color.fromRGBO(4, 131, 184, .5),
};

LinearGradient medalGradiant = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [myColor.shade50, myColor.shade900]);