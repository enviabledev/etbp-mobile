import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:etbp_mobile/app.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: EtbpApp()));
    expect(find.byType(EtbpApp), findsOneWidget);
  });
}
