import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:ss_preventer/ss_preventer.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('preventOn/preventOff does not throw', (
    WidgetTester tester,
  ) async {
    await SsPreventer.preventOn();
    await SsPreventer.preventOff();

    expect(true, isTrue);
  });
}
