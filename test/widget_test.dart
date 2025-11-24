import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wheel_of_time_app/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(
      const ProviderScope(
        child: WheelOfTimeApp(),
      ),
    );

    // Initial pump
    await tester.pump();

    // App should show loading indicator initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
hat we use ansible