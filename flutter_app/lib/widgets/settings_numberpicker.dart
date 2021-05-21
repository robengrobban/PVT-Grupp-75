import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

// ignore: must_be_immutable
class SettingsNumberPicker extends StatelessWidget {

  Axis alignment;
  int value;
  int minValue;
  int maxValue;
  int stepSize;
  Axis axis;
  Function callback;

  SettingsNumberPicker(this.value, this.minValue, this. maxValue, this.callback, {this.stepSize = 1, this.axis = Axis.vertical});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: NumberPicker(
        value: value,
        step: stepSize,
        minValue: minValue,
        maxValue: maxValue,
        axis: axis,
        onChanged: callback,
      )
    );

  }

}
