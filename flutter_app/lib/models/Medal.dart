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
  THIRTY_DAY_STREAK
}

extension ColorExtension on MedalType {
  Color get color {
    switch (this) {
      case MedalType.THREE_DAY_STREAK:
        print("Three day streak");
        return Colors.yellowAccent;
      case MedalType.FIVE_DAY_STREAK:
        print("Five day streak");
        return Colors.blue;
      case MedalType.TEN_DAY_STREAK:
        print("Ten day streak");
        return Colors.lightGreenAccent;
      case MedalType.FIFTEEN_DAY_STREAK:
        print("Fifteen day streak");
        return Colors.red;
      case MedalType.TWENTY_DAY_STREAK:
        print("Twenty day streak");
        return Colors.purpleAccent;
      case MedalType.THIRTY_DAY_STREAK:
        print("Thirty day streak");
        return Colors.deepOrange;
    }
  }
}

extension TitleExtension on MedalType {
  String get string {
    switch (this) {
      case MedalType.THREE_DAY_STREAK:
        return "Three day streak";
      case MedalType.FIVE_DAY_STREAK:
        return "Five day streak";
      case MedalType.TEN_DAY_STREAK:
        return "Ten day streak";
      case MedalType.FIFTEEN_DAY_STREAK:
        return "Fifteen day streak";
      case MedalType.TWENTY_DAY_STREAK:
        return "Twenty day streak";
      case MedalType.THIRTY_DAY_STREAK:
        return "Thirty day streak";
    }
  }
}
