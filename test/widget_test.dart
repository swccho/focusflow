import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:focusflow/app/app.dart';

void main() {
  testWidgets('Dashboard shows Pomodoro card', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FocusFlowApp(),
      ),
    );

    expect(find.text('Focus'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
  });
}
