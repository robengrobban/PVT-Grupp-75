import 'package:flutter/material.dart';

class DropDown<T> extends StatefulWidget {
  final T startValue;
  final List<T> values;
  final Function(T) toText;
  final Function(T) valueReturned;

  const DropDown({Key key, @required this.startValue, @required this.values, @required this.valueReturned, @required this.toText}) : super(key: key);

  @override
  DropDownState<T> createState() =>DropDownState<T>();
}

class DropDownState<T> extends State<DropDown<T>> {
  T selected;

  @override
  void initState() {
    super.initState();
    selected = widget.startValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5)),
        padding: EdgeInsets.only(left: 10, right: 10),
        margin: EdgeInsets.all(20),
        child: DropdownButton(
          underline: SizedBox(),
          value: selected,
          items: widget.values
              .map<DropdownMenuItem<T>>((T value) {
            return DropdownMenuItem<T>(
              value: value,
              child: Container(
                  width: 150,
                  child: Text(widget.toText(value),
                      style: TextStyle(fontSize: 16))),
            );
          }).toList(),
          iconSize: 24,
          onChanged: (value) {
            setState(() {
              selected = value;
              widget.valueReturned(value);
            });
          },
        ));
  }

}