// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chat_app/main.dart';

void main() {
  testWidgets('Test authentication screen UI',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());

    expect(find.text('Authentication'), findsOneWidget);

    expect(find.byType(Form), findsOneWidget);

    expect(find.widgetWithText(TextFormField, 'Email Address'), findsOneWidget);

    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);

    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });
}
