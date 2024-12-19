// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todouxproject/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(projets: [],));

    // Since the '+' icon and its functionality are not directly testable here,
    // let's just verify that the initial state of the app is correct.

    // Example verification (replace this with relevant tests for your app):
    // Verify that there is a message indicating no projects are registered.
    expect(find.text("Aucun projet enregistré"), findsOneWidget);

    // Example of checking for a button/icon
    expect(find.byIcon(Icons.add), findsOneWidget);

    // Example of tapping the add button (this doesn't perform a real tap, just verifies if it exists)
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Example verification after tapping the add button
    // Verify that the message indicating no projects are registered is gone
    expect(find.text("Aucun projet enregistré"), findsNothing);
  });
}

