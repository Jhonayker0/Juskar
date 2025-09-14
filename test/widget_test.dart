// This is a basic Flutter widget test for the Juskar app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:juskar/main.dart';

void main() {
  testWidgets('Juskar app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const JuskarApp());

    // Verify that the app loads and shows the main page title
    expect(find.text('Página Principal'), findsOneWidget);
    
    // Verify that the search bar is present
    expect(find.text('Buscar pedido...'), findsOneWidget);
    
    // Verify that navigation bar is present
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Categorías'), findsOneWidget);
  });

  testWidgets('Navigation between screens works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const JuskarApp());

    // Tap on Categories tab
    await tester.tap(find.text('Categorías'));
    await tester.pump();

    // Verify that we're now on the Categories screen
    expect(find.text('Categorías'), findsWidgets);
    
    // Tap on Home tab
    await tester.tap(find.text('Inicio'));
    await tester.pump();

    // Verify that we're back on the home screen
    expect(find.text('Página Principal'), findsOneWidget);
  });
}
