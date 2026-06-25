import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
import 'package:provider/provider.dart';
import 'package:agrilink/main.dart';
import 'package:agrilink/data/services/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: const AgriLinkApp(),
      ),
    );

    // Verify that the app is constructed successfully.
    expect(find.byType(AgriLinkApp), findsOneWidget);

    // Advance virtual clock to let splash navigation timers execute
    await tester.pump(const Duration(seconds: 3));
  });
}
