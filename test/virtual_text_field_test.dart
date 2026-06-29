import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_keyboard/virtual_keyboard.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: VirtualKeyboardScope(
        child: Scaffold(body: child),
      ),
    );

Finder _key(String label) => find.byKey(ValueKey('vk_KeyKind.character_$label'));

void main() {
  testWidgets('keyboard appears on focus and hides on unfocus', (tester) async {
    final controller = TextEditingController();
    final focus = FocusNode();
    await tester.pumpWidget(_wrap(
      VirtualTextField(controller: controller, focusNode: focus),
    ));

    expect(find.byType(KeyboardView), findsNothing);

    focus.requestFocus();
    await tester.pumpAndSettle();
    expect(find.byType(KeyboardView), findsOneWidget);

    focus.unfocus();
    await tester.pumpAndSettle();
    expect(find.byType(KeyboardView), findsNothing);
  });

  testWidgets('tapping keys edits the field and preserves cursor', (tester) async {
    final controller = TextEditingController();
    final focus = FocusNode();
    await tester.pumpWidget(_wrap(
      VirtualTextField(controller: controller, focusNode: focus),
    ));

    focus.requestFocus();
    await tester.pumpAndSettle();

    // Auto-shift makes the first letter upper-case.
    await tester.tap(_key('h'));
    await tester.pump();
    expect(controller.text, 'H');

    await tester.tap(_key('i'));
    await tester.pump();
    expect(controller.text, 'Hi');
    expect(controller.selection.baseOffset, 2);
  });

  testWidgets('backspace deletes the previous character', (tester) async {
    final controller = TextEditingController(text: 'abc');
    final focus = FocusNode();
    await tester.pumpWidget(_wrap(
      VirtualTextField(controller: controller, focusNode: focus),
    ));
    focus.requestFocus();
    await tester.pumpAndSettle();
    controller.selection = const TextSelection.collapsed(offset: 3);

    await tester.tap(find.byKey(const ValueKey('vk_KeyKind.backspace_null')));
    await tester.pump();
    expect(controller.text, 'ab');
  });

  testWidgets('next action moves focus to the following field', (tester) async {
    final f1 = FocusNode();
    final f2 = FocusNode();
    await tester.pumpWidget(_wrap(
      Column(children: [
        VirtualTextField(focusNode: f1, textInputAction: TextInputAction.next),
        VirtualTextField(focusNode: f2),
      ]),
    ));

    f1.requestFocus();
    await tester.pumpAndSettle();
    expect(f1.hasFocus, isTrue);

    await tester.tap(find.byKey(const ValueKey('vk_KeyKind.enter_null')));
    await tester.pumpAndSettle();
    expect(f2.hasFocus, isTrue);
  });
}
