import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_v_keyboard/flutter_v_keyboard.dart';

void main() {
  testWidgets('desktopFormFactor renders DesktopFullKeyboard and types',
      (tester) async {
    tester.view.physicalSize = const Size(1470, 956);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final text = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => VKeyboardScope(
          config: const VKeyboardConfig(
            desktopFormFactor: KeyboardLayoutType.layout60,
            persistLayoutSelection: false,
            enableClipboardHistory: false,
            syncSystemClipboard: false,
          ),
          child: child!,
        ),
        home: Scaffold(
          body: VTextField(
            controller: text,
            keyboardType: VKeyboardType.desktop,
          ),
        ),
      ),
    );
    await tester.tap(find.byType(VTextField));
    await tester.pumpAndSettle();

    expect(find.byType(DesktopFullKeyboard), findsOneWidget);
    expect(find.byType(KeyboardView), findsNothing);
    // 60%: no function row.
    expect(find.text('F1'), findsNothing);

    final box =
        tester.renderObject<RenderBox>(find.byType(DesktopFullKeyboard));
    expect(box.size.width, closeTo(1470, 0.5));

    await tester.tap(find.text('q').last);
    await tester.tap(find.text('w').last);
    await tester.pumpAndSettle();
    expect(text.text, 'qw');

    // Keys must get Material text defaults even though the scope sits above
    // the Navigator (no yellow-underline fallback style).
    final keyText = tester.widget<Text>(find.text('q').last);
    final style = DefaultTextStyle.of(tester.element(find.text('q').last));
    expect(keyText.style?.decoration ?? style.style.decoration,
        isNot(TextDecoration.underline));
    expect(style.style.decoration, isNot(TextDecoration.underline));
    expect(tester.takeException(), isNull);
  });
}
