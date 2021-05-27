//import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Medal {
  MedalType type;

  Medal({this.type});
}

enum MedalType {
  THREE_DAY_STREAK,
  FIVE_DAY_STREAK,
  TEN_DAY_STREAK,
  FIFTEEN_DAY_STREAK,
  TWENTY_DAY_STREAK,
  THIRTY_DAY_STREAK,
  THREE_WALK_ONE_DAY,
  FIVE_WALK_ONE_DAY,
  WALK_FIFTY_KM_TOTAL,
  WALK_75_KM_TOTAL,
  WALK_HUNDRED_KM_TOTAL,
}

extension ColorExtension on MedalType {
  Color get color {
    switch (this) {
      case MedalType.THREE_DAY_STREAK:
        return Colors.orange.shade900.withOpacity(0.9);
      case MedalType.FIVE_DAY_STREAK:
        return myColor.shade300.withOpacity(0.9);
      case MedalType.TEN_DAY_STREAK:
        return Colors.yellow.shade400.withOpacity(0.9);
      case MedalType.FIFTEEN_DAY_STREAK:
        return Colors.grey.shade600.withOpacity(0.9);
      case MedalType.THREE_WALK_ONE_DAY:
        return Colors.purpleAccent.withOpacity(0.9);
      case MedalType.THIRTY_DAY_STREAK:
        return Colors.green.withOpacity(0.9);
    }
  }
}

extension TitleExtension on MedalType {
  String get string {
    switch (this) {
      case MedalType.THREE_DAY_STREAK:
        return "3 day streak";
      case MedalType.FIVE_DAY_STREAK:
        return "5 day streak";
      case MedalType.TEN_DAY_STREAK:
        return "10 day streak";
      case MedalType.FIFTEEN_DAY_STREAK:
        return "15 day streak";
      case MedalType.TWENTY_DAY_STREAK:
        return "20 day streak";
      case MedalType.THIRTY_DAY_STREAK:
        return "30 day streak";
    }
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
