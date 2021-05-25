import 'dart:developer';
import 'dart:io';

import 'package:flutter_app/models/account_handler.dart';
import 'package:flutter_app/models/event.dart';
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

  group('Events', () {

    test('Event parsing', () async {

      AccountHandler().init(fetcher: fakeGoogleCalendarFetcher);
      AccountHandler().clearCache();

      List<Event> events = await AccountHandler().events();

      expect(events[0].id(), "7fdf65mdhi4hc4sje9fuedmp75");
      expect(events[0].summary(), "asd");
      expect(events[1].id(), "6954td4smqo2e9oc38rnpkpfta");
      expect(events[1].summary(), "asd2");

    });

  });

}