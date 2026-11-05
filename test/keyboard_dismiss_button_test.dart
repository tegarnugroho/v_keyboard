import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_v_keyboard/flutter_v_keyboard.dart';

void main() {
  group('VKeyboardConfig - showHideKeyboardButton', () {
    test('defaults to true', () {
      const config = VKeyboardConfig();
      expect(config.showHideKeyboardButton, isTrue);
    });

    test('copyWith updates showHideKeyboardButton', () {
      const config = VKeyboardConfig();
      final updated = config.copyWith(showHideKeyboardButton: false);
      expect(updated.showHideKeyboardButton, isFalse);
      expect(updated.hideOnDone, isTrue);

      final reverted = updated.copyWith(showHideKeyboardButton: true);
      expect(reverted.showHideKeyboardButton, isTrue);
    });
  });

  group('Keyboard dismiss arrow button', () {
    testWidgets(
        'renders down-arrow close button below keys and closes keyboard on tap',
        (tester) async {
      final textController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VKeyboardScope(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: VTextField(
                  controller: textController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
              ),
            ),
          ),
        ),
      );

      // Initially no keyboard
      expect(find.byType(KeyboardView), findsNothing);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNothing);

      // Tap text field to show keyboard
      await tester.tap(find.byType(VTextField));
      await tester.pumpAndSettle();

      // Keyboard is now visible
      expect(find.byType(KeyboardView), findsOneWidget);

      // Down arrow button is present with semantic label and tooltip
      final dismissFinder = find.byIcon(Icons.keyboard_arrow_down_rounded);
      expect(dismissFinder, findsOneWidget);
      expect(
        find.bySemanticsLabel('Close keyboard'),
        findsOneWidget,
      );

      // Tap dismiss arrow button
      await tester.tap(dismissFinder);
      await tester.pumpAndSettle();

      // Keyboard is now dismissed / hidden
      expect(find.byType(KeyboardView), findsNothing);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNothing);
    });

    testWidgets('omits dismiss button when showHideKeyboardButton is false',
        (tester) async {
      final textController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VKeyboardScope(
              config: const VKeyboardConfig(showHideKeyboardButton: false),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: VTextField(
                  controller: textController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
              ),
            ),
          ),
        ),
      );

      // Tap text field to show keyboard
      await tester.tap(find.byType(VTextField));
      await tester.pumpAndSettle();

      // Keyboard is visible, but dismiss button is omitted
      expect(find.byType(KeyboardView), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNothing);
      expect(find.bySemanticsLabel('Close keyboard'), findsNothing);
    });

    testWidgets('omits dismiss button by default in desktop layout',
        (tester) async {
      final textController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VKeyboardScope(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: VTextField(
                  controller: textController,
                  keyboardType: VKeyboardType.desktop,
                  decoration: const InputDecoration(labelText: 'Desktop Field'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(VTextField));
      await tester.pumpAndSettle();

      expect(find.byType(KeyboardView), findsOneWidget);
      expect(find.bySemanticsLabel('Close keyboard'), findsNothing);
    });

    testWidgets('supports custom hideIcon and onHide callback in KeyboardView',
        (tester) async {
      final controller = VKeyboardController();
      final theme = VKeyboardTheme.light();
      const metrics = KeyboardMetrics(
        height: 240,
        maxWidth: 600,
        horizontalPadding: 8,
        rowSpacing: 6,
        formFactor: DeviceFormFactor.phone,
        isLandscape: false,
      );

      var hideTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyboardView(
              controller: controller,
              theme: theme,
              metrics: metrics,
              rows: const [],
              bottomSafeArea: 0,
              showHideKeyboardButton: true,
              hideIcon: Icons.keyboard_hide_rounded,
              onHide: () => hideTapped = true,
            ),
          ),
        ),
      );

      final customIconFinder = find.byIcon(Icons.keyboard_hide_rounded);
      expect(customIconFinder, findsOneWidget);

      await tester.tap(customIconFinder);
      await tester.pumpAndSettle();

      expect(hideTapped, isTrue);
    });

    testWidgets('EmojiPanel displays close button when bottomSafeArea > 0',
        (tester) async {
      final controller = VKeyboardController();
      final theme = VKeyboardTheme.light();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmojiPanel(
              controller: controller,
              theme: theme,
              height: 250,
              maxWidth: 400,
              bottomSafeArea: 36,
            ),
          ),
        ),
      );

      final dismissFinder = find.byIcon(Icons.keyboard_arrow_down_rounded);
      expect(dismissFinder, findsOneWidget);

      await tester.tap(dismissFinder);
      await tester.pumpAndSettle();

      expect(controller.isVisible, isFalse);
    });
  });
}
