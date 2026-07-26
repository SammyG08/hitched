import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hitched/app/hitched_app.dart';

void main() {
  testWidgets('Hitched app opens registration experience', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: HitchedApp()));
    await tester.pumpAndSettle();

    expect(find.text('Hitched'), findsOneWidget);
    expect(find.text('Welcome to Hitched'), findsOneWidget);
  });
}
