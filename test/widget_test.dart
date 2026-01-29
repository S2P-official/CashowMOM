import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:factory_app/main.dart';
import 'package:factory_app/state/auth_provider.dart'; // import your AuthProvider if needed

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Create a dummy AuthProvider if your app requires it
    final authProvider = AuthProvider(); // adjust if constructor requires params

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MyApp(
        authProvider: authProvider,
        isLoggedIn: false, // or true depending on your test
      ),
    );

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
