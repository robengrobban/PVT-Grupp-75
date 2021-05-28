extension DateHelper on DateTime {
  DateTime getBeginningOfDay() {
    return DateTime(this.year, this.month, this.day);
  }

  DateTime getEndOfDay() {
    return getBeginningOfDay().add(Duration(days:1)).subtract(Duration(milliseconds: 1));
  }

  DateTime getBeginningOfWeek() {
    return subtract(Duration(days: weekday -1)).getBeginningOfDay();
  }

  DateTime getEndOfWeek() {
    return add(Duration(days: DateTime.daysPerWeek - weekday)).getEndOfDay();
  }
}