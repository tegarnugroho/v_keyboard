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
}

