import 'package:flutter_test/flutter_test.dart';

import 'package:ss_preventer_example/main.dart';

void main() {
  testWidgets('renders prevent screenshot switch', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Prevent Screenshot'), findsOneWidget);
    expect(find.text('Event Logs'), findsOneWidget);
  });
}
