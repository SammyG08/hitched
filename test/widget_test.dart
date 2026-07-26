import 'package:flutter_test/flutter_test.dart';
import 'package:hitched/main.dart';

void main() {
  testWidgets('Hitched app opens registration experience', (tester) async {
    await tester.pumpWidget(const HitchedApp());
    await tester.pumpAndSettle();

    expect(find.text('Hitched'), findsOneWidget);
    expect(find.text('Create linked couple account'), findsOneWidget);
  });
}
