import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:agrilink/screens/orders/order_tracking_screen.dart';

// We test the UI widget in isolation using a mock-aware approach.
// The screen accepts orderId/orderCode as constructor params — no Provider needed.

void main() {
  group('OrderTrackingScreen — widget structure', () {
    Widget _wrap(Widget child) => MaterialApp(home: child);

    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(const OrderTrackingScreen(
        orderId: 'order123',
        orderCode: 'AGL-001',
      )));
      // Initial frame renders
      await tester.pump();
      expect(find.byType(OrderTrackingScreen), findsOneWidget);
    });

    testWidgets('shows order code in top bar', (tester) async {
      await tester.pumpWidget(_wrap(const OrderTrackingScreen(
        orderId: 'order123',
        orderCode: 'AGL-20260710-001',
      )));
      await tester.pump();
      expect(find.textContaining('AGL-20260710-001'), findsOneWidget);
    });

    testWidgets('shows back button', (tester) async {
      await tester.pumpWidget(_wrap(const OrderTrackingScreen(
        orderId: 'order123',
        orderCode: 'AGL-001',
      )));
      await tester.pump();
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('back button pops navigator', (tester) async {
      bool popped = false;
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (ctx) {
          return TextButton(
            onPressed: () {
              Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (_) => const OrderTrackingScreen(
                    orderId: 'order123',
                    orderCode: 'AGL-001',
                  ),
                ),
              );
            },
            child: const Text('Go'),
          );
        }),
        navigatorObservers: [
          _PopObserver(onPop: () => popped = true),
        ],
      ));

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });

    testWidgets('shows FlutterMap widget', (tester) async {
      await tester.pumpWidget(_wrap(const OrderTrackingScreen(
        orderId: 'order123',
        orderCode: 'AGL-001',
      )));
      await tester.pump();
      expect(find.byType(FlutterMap), findsOneWidget);
    });

    testWidgets('shows wifi icon in top bar', (tester) async {
      await tester.pumpWidget(_wrap(const OrderTrackingScreen(
        orderId: 'order123',
        orderCode: 'AGL-001',
      )));
      await tester.pump();
      // Initially disconnected (no real server in test)
      expect(
        find.byIcon(Icons.wifi_off).evaluate().isNotEmpty ||
            find.byIcon(Icons.wifi).evaluate().isNotEmpty,
        isTrue,
      );
    });
  });

  group('OrderTrackingScreen — constructor params', () {
    test('accepts orderId, orderCode, optional token', () {
      const screen = OrderTrackingScreen(
        orderId: 'abc',
        orderCode: 'AGL-XYZ',
        token: 'jwt-token-here',
      );
      expect(screen.orderId, 'abc');
      expect(screen.orderCode, 'AGL-XYZ');
      expect(screen.token, 'jwt-token-here');
    });

    test('token defaults to null', () {
      const screen = OrderTrackingScreen(
        orderId: 'abc',
        orderCode: 'AGL-XYZ',
      );
      expect(screen.token, isNull);
    });
  });
}

class _PopObserver extends NavigatorObserver {
  final VoidCallback onPop;
  _PopObserver({required this.onPop});

  @override
  void didPop(Route route, Route? previousRoute) {
    onPop();
  }
}
