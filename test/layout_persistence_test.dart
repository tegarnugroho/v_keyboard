import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_v_keyboard/flutter_v_keyboard.dart';

void main() {
  group('Layout Persistence & State', () {
    test('InMemoryLayoutSelectionStorage saves, loads and clears layout id', () async {
      final storage = InMemoryLayoutSelectionStorage();
      expect(await storage.load(), isNull);

      await storage.save('de_DE');
      expect(await storage.load(), 'de_DE');

      await storage.clear();
      expect(await storage.load(), isNull);
    });

    test('controller saves layout to storage on setLayout', () async {
      final storage = InMemoryLayoutSelectionStorage();
      final controller = VKeyboardController(
        config: const VKeyboardConfig(
          enabledLayouts: ['en_US', 'de_DE', 'fr_FR'],
          persistLayoutSelection: true,
        ),
        layoutStorage: storage,
      );

      controller.setLayout('de_DE');
      expect(await storage.load(), 'de_DE');

      controller.setLayout('fr_FR');
      expect(await storage.load(), 'fr_FR');
    });

    test('new controller restores previously persisted layout', () async {
      final storage = InMemoryLayoutSelectionStorage('tr_TR');
      final controller = VKeyboardController(
        config: const VKeyboardConfig(
          enabledLayouts: ['en_US', 'de_DE', 'tr_TR'],
          persistLayoutSelection: true,
        ),
        layoutStorage: storage,
      );

      // Wait for asynchronous restore
      await Future.delayed(const Duration(milliseconds: 20));
      expect(controller.currentLayoutId, 'tr_TR');
    });

    testWidgets('switching layout preserves text and cursor position',
        (tester) async {
      final controller = VKeyboardController(
        config: const VKeyboardConfig(
          enabledLayouts: ['en_US', 'de_DE'],
          persistLayoutSelection: false,
        ),
      );
      final textController = TextEditingController(text: 'Hello');
      textController.selection = const TextSelection.collapsed(offset: 3);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VKeyboardScope(
              controller: controller,
              child: VTextField(controller: textController),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(VTextField));
      await tester.pumpAndSettle();

      textController.selection = const TextSelection.collapsed(offset: 3);
      expect(textController.text, 'Hello');
      expect(textController.selection.baseOffset, 3);

      // Switch layout
      controller.setLayout('de_DE');
      await tester.pumpAndSettle();

      expect(textController.text, 'Hello');
      expect(textController.selection.baseOffset, 3);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('switching layout while on symbols page returns to initial page',
        (tester) async {
      final controller = VKeyboardController(
        config: const VKeyboardConfig(
          enabledLayouts: ['en_US', 'de_DE'],
          persistLayoutSelection: false,
        ),
      );
      final textController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VKeyboardScope(
              controller: controller,
              child: VTextField(controller: textController),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(VTextField));
      await tester.pumpAndSettle();

      // Switch to '123' page
      controller.switchPage('123');
      expect(controller.currentPage, '123');

      // Switch layout to de_DE
      controller.setLayout('de_DE');
      expect(controller.currentPage, 'abc');
      await tester.pump(const Duration(seconds: 2));
    });
  });
}
