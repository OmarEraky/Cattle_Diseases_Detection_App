import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cattle_disease_app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: CattleDiseaseApp(),
      ),
    );

    // Verify that the splash/home title is present.
    expect(find.text('Cattle Health AI'), findsOneWidget);
  });
}
