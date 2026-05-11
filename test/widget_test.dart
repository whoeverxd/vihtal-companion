// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:vihtal_companion/main.dart';
import 'package:vihtal_companion/widgets/brand_logo.dart';

void main() {
  testWidgets('App arranca en Splash y navega a Login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.byType(BrandLogo), findsOneWidget);
    expect(find.text('EMPEZAR'), findsOneWidget);

    // Navegar a login
    await tester.tap(find.text('EMPEZAR'));
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
