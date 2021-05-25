
import 'dart:io';

import 'package:flutter_app/models/account_handler.dart';
import 'package:flutter_app/models/notification_handler.dart';
import 'package:flutter_app/models/notification_spot.dart';
import 'package:flutter_app/util/google_calendar_fetcher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert' show json;

class FakeGoogleCalendarFetcher extends GoogleCalendarFetcher {

  final File file = File('assets/test/fake_google_calendar_data.txt');

  @override
  Future<Map<String, dynamic>> fetchCalendar(GoogleSignInAccount user) async {
    final String jsonData = await file.readAsString();
    return json.decode(jsonData);
  }

}

void main() {

  final FakeGoogleCalendarFetcher fakeGoogleCalendarFetcher = FakeGoogleCalendarFetcher();

  group('Notification Spot', () {

    test('Constructor test', () async {

      final int id = 12192;
      final DateTime startTime = DateTime.now();
      final DateTime endTime = DateTime.now().add(Duration(days: 1));

      NotificationSpot testSpot = NotificationSpot(id, startTime, endTime);

      expect(testSpot.id(), id);
      expect(testSpot.startTime(), startTime);
      expect(testSpot.endTime(), endTime);

    });

    test('Spot correct duration in minutes', () async {

      final int id = 12912;
      final DateTime startTime = DateTime.now();
      final DateTime endTime = DateTime.now().add(Duration(minutes: 1));

      NotificationSpot testSpot = NotificationSpot(id, startTime, endTime);

      expect(testSpot.durationInMinutes(), 1);

    });

  });

  group('Notification Handler', () {

    test('Settings cast exception on max notification less than zero', () async {

      final int newMaxNotifications = -1;
      final int newWalkLength = 1200;
      final bool newAffectedByWeather = false;

      expect(() async => await NotificationHandler().updateSettings(newMaxNotifications, newWalkLength, newAffectedByWeather), throwsException);

    });

    test('Settings cast exception on walk length less than 20', () async {

      final int newMaxNotifications = 120;
      final int newWalkLength = 19;
      final bool newAffectedByWeather = false;

      expect(() async => await NotificationHandler().updateSettings(newMaxNotifications, newWalkLength, newAffectedByWeather), throwsException);

    });

    test('Correctly generate notification spots', () async {

      await AccountHandler().init(fetcher: fakeGoogleCalendarFetcher);

      List<NotificationSpot> testSpots = NotificationHandler().generateNotificationSpots( await AccountHandler().events() );

      expect(testSpots.length, 1);
      expect(testSpots[0].id(), 489267528);

      AccountHandler().clearCache();
      
    });

  });

}