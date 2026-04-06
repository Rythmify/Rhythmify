import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rythmify/main.dart' as app;
void main() {
IntegrationTestWidgetsFlutterBinding.ensureInitialized();
testWidgets('bootstrap', (tester) async {
app.main();
await tester.pumpAndSettle();
});
}