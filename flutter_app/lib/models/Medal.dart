import 'package:flutter/material.dart';

class Medal {
  MedalType type;

  Medal({this.type});

}

enum MedalType {
  THREE_DAY_STREAK,
  FIVE_DAY_STREAK
}

extension ColorExtension on MedalType {
  Color get color {
    switch (this) {
      case MedalType.THREE_DAY_STREAK:
        return Colors.red;
      case MedalType.FIVE_DAY_STREAK:
        return Colors.blue;
    }
  }
}