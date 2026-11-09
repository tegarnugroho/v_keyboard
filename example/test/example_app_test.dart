import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_keyboard_example/main.dart';

void main() {
  testWidgets('ExampleApp renders cleanly on Desktop (1440x900)', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('Virtual Keyboard'), findsWidgets);
    expect(find.text('Try it out'), findsOneWidget);
    expect(find.text('Keyboard preview'), findsOneWidget);
    expect(find.text('Playground'), findsWidgets);
    expect(find.text('Quick examples'), findsOneWidget);
  });

  testWidgets('ExampleApp renders cleanly on compact desktop (1024x665)', (tester) async {
    tester.view.physicalSize = const Size(1024 * 2, 665 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('Virtual Keyboard'), findsWidgets);
    expect(find.text('Try it out'), findsOneWidget);
    expect(find.text('Quick examples'), findsOneWidget);
  });

  testWidgets('ExampleApp renders cleanly on Tablet (820x1180)', (tester) async {
    tester.view.physicalSize = const Size(820, 1180);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('Virtual Keyboard'), findsWidgets);
    expect(find.text('Try it out'), findsOneWidget);
  });

  testWidgets('ExampleApp renders cleanly on Mobile (390x844)', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('Virtual Keyboard'), findsWidgets);
    expect(find.text('Try it out'), findsOneWidget);
  });

  testWidgets('ExampleApp allows switching tabs without throwing locked tree exceptions', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    // Tap Desktop Keyboard tab
    await tester.tap(find.text('Desktop Keyboard').first);
    await tester.pumpAndSettle();
    expect(find.text('Full Desktop Keyboard (OSK Style)'), findsOneWidget);

    // Tap Keyboard Types tab
    await tester.tap(find.text('Keyboard Types').first);
    await tester.pumpAndSettle();
    expect(find.text('Keyboard Types Showcase'), findsOneWidget);

    // Tap Customization tab
    await tester.tap(find.text('Customization').first);
    await tester.pumpAndSettle();
    expect(find.text('Live Customization & Theme'), findsOneWidget);

    // Tap Examples tab
    await tester.tap(find.text('Examples').first);
    await tester.pumpAndSettle();
    expect(find.text('Pre-built Scenarios & Examples'), findsOneWidget);
    expect(find.text('Scenario 1: Checkout Form Flow'), findsOneWidget);

    // Tap Playground tab
    await tester.tap(find.text('Playground').first);
    await tester.pumpAndSettle();
    expect(find.text('Try it out'), findsOneWidget);
  });

  testWidgets('ExampleApp toggles sidebar hide and expand', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('Hide sidebar'), findsOneWidget);

    // Tap Hide sidebar
    await tester.tap(find.text('Hide sidebar'));
    await tester.pumpAndSettle();

    expect(find.text('Show sidebar'), findsOneWidget);

    // Tap Show sidebar to re-expand
    await tester.tap(find.text('Show sidebar'));
    await tester.pumpAndSettle();

    expect(find.text('Hide sidebar'), findsOneWidget);
  });
}

