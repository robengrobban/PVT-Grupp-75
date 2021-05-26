
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/menu_screen.dart';
import 'package:flutter_app/screens/settings_screen.dart';
import 'package:flutter_app/screens/success_screen.dart';
import 'package:flutter_app/widgets/menu_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  testWidgets('Open Achievements', (WidgetTester tester) async {

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => MenuScreen(),
          '/success': (context) => SuccessScreen()
        },
      )
    );

    await tester.tap(find.byType(MenuItem).at(1));

    await tester.pumpAndSettle();

    expect(find.text("Awards"), findsOneWidget);

  });

}