//import 'dart:html';

import 'package:flutter/foundation.dart';

import 'medal_repository.dart';


class Medal {
  MedalType type;
  int value;
  DateTime timeEarned;

  Medal({this.type, this.value, this.timeEarned});

  factory Medal.fromJson(Map<String, dynamic> json) {
    return Medal(
      value: (json['value'] as int),
      timeEarned: (DateTime.parse(json['timeEarned'])),

      type: (MedalType.values.firstWhere((e) => describeEnum(e) == json['type'])),
    );
  }

  Map<String,dynamic> toJson() {
    var map = Map<String,dynamic>();
    map["type"] = describeEnum(type);
    map["value"] = value;
    map["timeEarned"] = timeEarned.toIso8601String();
    return map;
  }

}






