import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aarshjulet/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(
      const ProviderScope(
        child: AarshjuletApp(),
      ),
    );

    // Initial pump
    await tester.pump();

    // Appen skal starte uden fejl og vise MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}