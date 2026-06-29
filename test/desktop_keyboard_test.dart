import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide ModifierKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:v_keyboard/v_keyboard.dart';
import 'package:v_keyboard/src/widgets/keyboard_key.dart';

Finder _charKey(String text) => find.byWidgetPredicate(
    (w) => w is VirtualKey && w.data.kind == KeyKind.character && w.data.text == text);

Finder _modKey(ModifierKey m) => find.byWidgetPredicate(
    (w) => w is VirtualKey && w.data.kind == KeyKind.modifier && w.data.modifier == m);

Finder _navKey(NavIntent n) => find.byWidgetPredicate(
    (w) => w is VirtualKey && w.data.kind == KeyKind.navigation && w.data.nav == n);

void main() {
  group('KeyboardModifierController', () {
    test('shift toggles upper case; caps locks', () {
      final m = KeyboardModifierController();
      expect(m.isUpperCase, isFalse);
      m.toggleModifier(ModifierKey.shift);
      expect(m.isUpperCase, isTrue);
      m.toggleModifier(ModifierKey.shift);
      expect(m.isUpperCase, isFalse);
      m.toggleLock(LockKey.capsLock);
      expect(m.isUpperCase, isTrue);
      // Shift while caps-locked inverts back to lower.
      m.toggleModifier(ModifierKey.shift);
      expect(m.isUpperCase, isFalse);
    });

    test('command modifiers and logical set', () {
      final m = KeyboardModifierController();
      m.toggleModifier(ModifierKey.control);
      expect(m.hasCommandModifier, isTrue);
      expect(m.logicalModifiers, contains(LogicalKeyboardKey.control));
    });
  });

  group('Desktop keyboard widget', () {
    Future<void> pumpDesktop(WidgetTester tester, TextEditingController c,
        FocusNode focus) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: VKeyboardScope(
          child: Scaffold(
            body: VTextField(
              controller: c,
              focusNode: focus,
              keyboardType: VKeyboardType.desktop,
            ),
          ),
        ),
      ));
      focus.requestFocus();
      await tester.pumpAndSettle();
    }

    testWidgets('renders and types lower case (no auto-shift)', (tester) async {
      final c = TextEditingController();
      final f = FocusNode();
      await pumpDesktop(tester, c, f);

      expect(find.byType(KeyboardView), findsOneWidget);
      await tester.tap(_charKey('a'));
      await tester.pump();
      expect(c.text, 'a');
    });

    testWidgets('shift modifier upper-cases the next letter', (tester) async {
      final c = TextEditingController();
      final f = FocusNode();
      await pumpDesktop(tester, c, f);

      await tester.tap(_modKey(ModifierKey.shift).first);
      await tester.pump();
      await tester.tap(_charKey('a'));
      await tester.pump();
      expect(c.text, 'A');
    });

    testWidgets('Ctrl+A selects all', (tester) async {
      final c = TextEditingController(text: 'hello');
      final f = FocusNode();
      await pumpDesktop(tester, c, f);
      c.selection = const TextSelection.collapsed(offset: 5);

      await tester.tap(_modKey(ModifierKey.control).first);
      await tester.pump();
      await tester.tap(_charKey('a'));
      await tester.pump();
      expect(c.selection.baseOffset, 0);
      expect(c.selection.extentOffset, 5);
    });

    testWidgets('left arrow moves the cursor', (tester) async {
      final c = TextEditingController(text: 'abc');
      final f = FocusNode();
      await pumpDesktop(tester, c, f);
      c.selection = const TextSelection.collapsed(offset: 3);

      await tester.tap(_navKey(NavIntent.left));
      await tester.pump();
      expect(c.selection.baseOffset, 2);
    });
  });
}
