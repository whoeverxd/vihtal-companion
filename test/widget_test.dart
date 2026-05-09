// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:vihtal_companion/main.dart';

void main() {
  testWidgets('App arranca en Splash y navega a Login', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Splash
    expect(find.text('VIHTAL'), findsOneWidget);
    expect(find.text('Companion'), findsOneWidget);
    expect(find.text('Seguro y Privado'), findsOneWidget);

    // Navegar a login
    await tester.tap(find.text('Seguro y Privado'));
    await tester.pumpAndSettle();

    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.text('Acceder'), findsOneWidget);
  });
}
