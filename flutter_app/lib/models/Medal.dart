//import 'dart:html';

import 'package:flutter/foundation.dart';

import 'medal_repository.dart';


class Medal {
  MedalType type;
  int value;
  DateTime timeEarned;

  Medal({this.type, this.value, this.timeEarned});

  factory Medal.fromJson(Map<String, dynamic> json) {
    print(MedalType.values);
    print(json);
    return Medal(
      value: (json['value'] as int),
      timeEarned: (DateTime.parse(json['timeEarned'])),

      type: (MedalType.values.firstWhere((e) => describeEnum(e) == json['type'])),
    );
  }
}






