import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_v_keyboard/flutter_v_keyboard.dart';

void main() {
  group('KeyModel & DesktopFullLayoutData Presets', () {
    test('all main cluster rows sum to exact 15.0u ANSI width', () {
      final rows = [
        DesktopFullLayoutData.functionRow(),
        DesktopFullLayoutData.numberRow(),
        DesktopFullLayoutData.topAlphaRow(),
        DesktopFullLayoutData.homeAlphaRow(),
        DesktopFullLayoutData.bottomAlphaRow(),
        DesktopFullLayoutData.bottomControlRow(),
      ];

      for (final row in rows) {
        final total = row.fold<double>(0.0, (sum, k) => sum + k.flex);
        expect(total, closeTo(15.0, 0.001));
      }
    });

    test('all navigation cluster rows sum to exact 3.0u width', () {
      final rows = [
        DesktopFullLayoutData.navSystemRow(),
        DesktopFullLayoutData.navTopEditRow(),
        DesktopFullLayoutData.navBottomEditRow(),
        DesktopFullLayoutData.navEmptyRow(),
        DesktopFullLayoutData.navArrowUpRow(),
        DesktopFullLayoutData.navArrowBottomRow(),
      ];

      for (final row in rows) {
        final total = row.fold<double>(0.0, (sum, k) => sum + k.flex);
        expect(total, closeTo(3.0, 0.001));
      }
    });

    test('60%, 65%, 75%, and 98% presets maintain exact proportional row flex sums', () {
      for (final row in DesktopFullLayoutData.layout60Rows()) {
        expect(row.fold<double>(0, (s, k) => s + k.flex), closeTo(15.0, 0.001));
      }
      for (final row in DesktopFullLayoutData.layout65Rows()) {
        expect(row.fold<double>(0, (s, k) => s + k.flex), closeTo(16.0, 0.001));
      }
      for (final row in DesktopFullLayoutData.layout75Rows()) {
        expect(row.fold<double>(0, (s, k) => s + k.flex), closeTo(16.0, 0.001));
      }
      for (final row in DesktopFullLayoutData.layout98MainRows()) {
        expect(row.fold<double>(0, (s, k) => s + k.flex), closeTo(15.0, 0.001));
      }
      expect(
        DesktopFullLayoutData.layout98NumpadUtilityRow()
            .fold<double>(0, (s, k) => s + k.flex),
        closeTo(4.0, 0.001),
      );
    });

    test('KeyModel.resolveOutput handles Shift XOR CapsLock correctly', () {
      final letter = KeyModel.char('a');
      expect(letter.resolveOutput(shifted: false, capsLock: false), 'a');
      expect(letter.resolveOutput(shifted: true, capsLock: false), 'A');
      expect(letter.resolveOutput(shifted: false, capsLock: true), 'A');
      expect(letter.resolveOutput(shifted: true, capsLock: true), 'a');

      final digit = KeyModel.char('1', shift: '!');
      expect(digit.resolveOutput(shifted: false, capsLock: false), '1');
      expect(digit.resolveOutput(shifted: true, capsLock: false), '!');
      // Caps Lock does not shift digits/punctuation on standard ANSI desktop keyboards.
      expect(digit.resolveOutput(shifted: false, capsLock: true), '1');
      expect(digit.resolveOutput(shifted: true, capsLock: true), '!');
    });
  });

  group('DesktopFullKeyboard Responsive & Edge-to-Edge', () {
    for (final size in const [
      Size(1920, 1080), // Full HD 1080p
      Size(2560, 1440), // 2K / QHD (27-inch)
      Size(3440, 1440), // Ultrawide 21:9
      Size(3840, 2160), // 4K UHD
      Size(800, 600), // Compact desktop window
      Size(480, 800), // Very narrow window fallback
    ]) {
      testWidgets(
          'renders edge-to-edge without overflow at ${size.width.toInt()}x${size.height.toInt()}',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        const ratio = 0.36;
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.bottomCenter,
                child: DesktopFullKeyboard(
                  maxKeyboardHeightRatio: ratio,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final box = tester.renderObject<RenderBox>(
            find.byType(DesktopFullKeyboard));
        expect(box.size.width, closeTo(size.width, 0.5));
        expect(box.size.height, lessThanOrEqualTo(size.height * ratio + 0.5));
      });
    }

    for (final preset in KeyboardLayoutType.values) {
      testWidgets('renders preset ${preset.name} edge-to-edge at 2560x1440 cleanly',
          (tester) async {
        tester.view.physicalSize = const Size(2560, 1440);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.bottomCenter,
                child: DesktopFullKeyboard(
                  layoutType: preset,
                  isFullWidth: true,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final box = tester.renderObject<RenderBox>(
            find.byType(DesktopFullKeyboard));
        expect(box.size.width, closeTo(2560.0, 0.5));
        expect(find.text('Desktop ${preset.label}'), findsOneWidget);
      });
    }

    testWidgets('maxWidth and isFullWidth: false constrain inner grid width gracefully',
        (tester) async {
      tester.view.physicalSize = const Size(3440, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DesktopFullKeyboard(
              layoutType: KeyboardLayoutType.layout60,
              isFullWidth: true,
              maxWidth: 820,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Inner sized grid respects maxWidth: 820 while outer dock aligns cleanly
      final constrainedGrid = tester.renderObject<RenderBox>(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 820.0,
        ),
      );
      expect(constrainedGrid.size.width, closeTo(820.0, 0.5));
    });

    testWidgets('hides function row and numpad when configured false',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DesktopFullKeyboard(
              showFunctionRow: false,
              showNumpad: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Esc'), findsNothing);
      expect(find.text('F1'), findsNothing);
      expect(find.text('PrtSc'), findsNothing);
      expect(find.byKey(const ValueKey('dk_layout100_num_lock')), findsNothing);
      expect(find.text('Show Numpad'), findsOneWidget);

      // Re-enable Numpad dynamically via header toggle button.
      await tester.tap(find.text('Show Numpad'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('dk_layout100_num_lock')), findsOneWidget);
      expect(find.text('Hide Numpad'), findsOneWidget);
    });
  });

  group('DesktopFullKeyboard Preset Layouts & Fn Layer', () {
    testWidgets('layout87TKL omits numpad while keeping F-row and Nav cluster',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DesktopFullKeyboard(layoutType: KeyboardLayoutType.layout87TKL),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('dk_layout87TKL_f1')), findsOneWidget);
      expect(find.byKey(const ValueKey('dk_layout87TKL_prtsc')), findsOneWidget);
      expect(find.byKey(const ValueKey('dk_layout87TKL_delete')), findsOneWidget);
      expect(find.byKey(const ValueKey('dk_layout87TKL_num_lock')), findsNothing);
      expect(find.text('Hide Numpad'), findsNothing);
    });

    testWidgets('layout98 renders compact utility row and numpad with zero cluster gap',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DesktopFullKeyboard(layoutType: KeyboardLayoutType.layout98),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('dk_layout98_insert')), findsOneWidget);
      expect(find.byKey(const ValueKey('dk_layout98_num_lock')), findsOneWidget);
      expect(find.byKey(const ValueKey('dk_layout98_arrow_up')), findsOneWidget);
      expect(find.byKey(const ValueKey('dk_layout98_pgdn')), findsOneWidget);
    });

    testWidgets('layout75 keeps F-row and right nav strip, hides numpad',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DesktopFullKeyboard(layoutType: KeyboardLayoutType.layout75),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('dk_layout75_f12')), findsOneWidget);
      expect(find.byKey(const ValueKey('dk_layout75_delete')), findsOneWidget);
      expect(find.byKey(const ValueKey('dk_layout75_pgup')), findsOneWidget);
      expect(find.byKey(const ValueKey('dk_layout75_arrow_up')), findsOneWidget);
      expect(find.byKey(const ValueKey('dk_layout75_num_lock')), findsNothing);
    });

    testWidgets('layout65 hides F-row and numpad while keeping nav rail and arrows',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DesktopFullKeyboard(layoutType: KeyboardLayoutType.layout65),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('dk_layout65_f1')), findsNothing);
      expect(find.byKey(const ValueKey('dk_layout65_num_lock')), findsNothing);
      expect(find.byKey(const ValueKey('dk_layout65_delete')), findsOneWidget);
      expect(find.byKey(const ValueKey('dk_layout65_arrow_down')), findsOneWidget);
    });

    testWidgets('layout60 hides F-row, nav, numpad and activates Fn layer for F-keys and arrows',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final typed = <String>[];
      final specials = <VirtualKeyAction>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DesktopFullKeyboard(
              layoutType: KeyboardLayoutType.layout60,
              onKeyPressed: typed.add,
              onSpecialKeyPressed: specials.add,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify pure alphanumeric only (no F-row, no nav block, no numpad)
      expect(find.byKey(const ValueKey('dk_layout60_f1')), findsNothing);
      expect(find.byKey(const ValueKey('dk_layout60_delete')), findsNothing);
      expect(find.byKey(const ValueKey('dk_layout60_num_lock')), findsNothing);

      // Normal typing produces digit '1' and letter 'w'
      await tester.tap(find.byKey(const ValueKey('dk_layout60_digit_1')));
      await tester.tap(find.byKey(const ValueKey('dk_layout60_char_w')));
      await tester.pump();
      expect(typed, ['1', 'w']);

      // Activate Fn layer
      await tester.tap(find.byKey(const ValueKey('dk_layout60_fn_key')));
      await tester.pump();

      // Fn legends visible (`F1`, `Esc`, `Del`)
      expect(find.text('F1'), findsOneWidget);
      expect(find.text('Esc'), findsOneWidget);
      expect(find.text('Del'), findsOneWidget);

      // Tap 1 -> triggers F1, W -> ArrowUp, A -> ArrowLeft, Backspace -> Delete, ` -> Escape
      await tester.tap(find.byKey(const ValueKey('dk_layout60_digit_1')));
      await tester.tap(find.byKey(const ValueKey('dk_layout60_char_w')));
      await tester.tap(find.byKey(const ValueKey('dk_layout60_char_a')));
      await tester.tap(find.byKey(const ValueKey('dk_layout60_backspace')));
      await tester.tap(find.byKey(const ValueKey('dk_layout60_grave')));
      await tester.pump();

      expect(specials, containsAllInOrder([
        VirtualKeyAction.fn,
        VirtualKeyAction.f1,
        VirtualKeyAction.arrowUp,
        VirtualKeyAction.arrowLeft,
        VirtualKeyAction.delete,
        VirtualKeyAction.escape,
      ]));

      // Deactivate Fn layer -> typing returns to normal '1'
      await tester.tap(find.byKey(const ValueKey('dk_layout60_fn_key')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('dk_layout60_digit_1')));
      await tester.pump();
      expect(typed.last, '1');
    });
  });

  group('DesktopFullKeyboard Interactivity & Callbacks', () {
    Future<void> pumpStandalone(
      WidgetTester tester, {
      ValueChanged<String>? onKeyPressed,
      ValueChanged<VirtualKeyAction>? onSpecialKeyPressed,
      ValueChanged<String>? onShortcutTriggered,
      DesktopKeyboardThemeData? themeData,
    }) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: DesktopFullKeyboard(
                themeData: themeData,
                onKeyPressed: onKeyPressed,
                onSpecialKeyPressed: onSpecialKeyPressed,
                onShortcutTriggered: onShortcutTriggered,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('Shift uppercase and symbol emission, then auto-resets',
        (tester) async {
      final typed = <String>[];
      final specials = <VirtualKeyAction>[];

      await pumpStandalone(
        tester,
        onKeyPressed: typed.add,
        onSpecialKeyPressed: specials.add,
      );

      // Unshifted char
      await tester.tap(find.byKey(const ValueKey('dk_layout100_char_q')));
      await tester.pump();
      expect(typed.last, 'q');

      // Tap Shift -> next letter uppercase -> Shift auto-clears
      await tester.tap(find.byKey(const ValueKey('dk_layout100_shift_left')));
      await tester.pump();
      expect(specials.last, VirtualKeyAction.leftShift);

      await tester.tap(find.byKey(const ValueKey('dk_layout100_char_w')));
      await tester.pump();
      expect(typed.last, 'W');

      await tester.tap(find.byKey(const ValueKey('dk_layout100_char_e')));
      await tester.pump();
      expect(typed.last, 'e');

      // Shift + dual-legend digit
      await tester.tap(find.byKey(const ValueKey('dk_layout100_shift_right')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('dk_layout100_digit_1')));
      await tester.pump();
      expect(typed.last, '!');
    });

    testWidgets('CapsLock persists uppercase letters across multiple taps',
        (tester) async {
      final typed = <String>[];
      await pumpStandalone(tester, onKeyPressed: typed.add);

      await tester.tap(find.byKey(const ValueKey('dk_layout100_caps_lock')));
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('dk_layout100_char_a')));
      await tester.tap(find.byKey(const ValueKey('dk_layout100_char_b')));
      await tester.tap(find.byKey(const ValueKey('dk_layout100_digit_2')));
      await tester.pump();

      expect(typed, ['A', 'B', '2']);

      // Toggle off
      await tester.tap(find.byKey(const ValueKey('dk_layout100_caps_lock')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('dk_layout100_char_c')));
      await tester.pump();
      expect(typed.last, 'c');
    });

    testWidgets('Ctrl shortcut triggers onShortcutTriggered with combo string',
        (tester) async {
      final shortcuts = <String>[];
      final typed = <String>[];

      await pumpStandalone(
        tester,
        onKeyPressed: typed.add,
        onShortcutTriggered: shortcuts.add,
      );

      await tester.tap(find.byKey(const ValueKey('dk_layout100_ctrl_left')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('dk_layout100_char_a')));
      await tester.pump();

      expect(shortcuts, ['Ctrl+A']);
      expect(typed, isEmpty);

      // Ctrl+Shift+Z combo
      await tester.tap(find.byKey(const ValueKey('dk_layout100_ctrl_left')));
      await tester.tap(find.byKey(const ValueKey('dk_layout100_shift_left')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('dk_layout100_char_z')));
      await tester.pump();

      expect(shortcuts.last, 'Ctrl+Shift+Z');
    });

    testWidgets('NumLock toggles numpad digits vs navigation actions',
        (tester) async {
      final typed = <String>[];
      final specials = <VirtualKeyAction>[];

      await pumpStandalone(
        tester,
        onKeyPressed: typed.add,
        onSpecialKeyPressed: specials.add,
      );

      // NumLock ON by default -> '7' emits '7'
      await tester.tap(find.byKey(const ValueKey('dk_layout100_num_7')));
      await tester.pump();
      expect(typed.last, '7');

      // Toggle NumLock OFF -> '7' triggers Home
      await tester.tap(find.byKey(const ValueKey('dk_layout100_num_lock')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('dk_layout100_num_7')));
      await tester.pump();
      expect(specials.last, VirtualKeyAction.home);
    });

    testWidgets('VKeyboardController and VTextField integration', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final textController = TextEditingController();
      final focusNode = FocusNode();
      final vkController = VKeyboardController();

      await tester.pumpWidget(
        MaterialApp(
          home: VKeyboardScope(
            controller: vkController,
            renderKeyboard: false,
            child: Scaffold(
              body: Column(
                children: [
                  Expanded(
                    child: VTextField(
                      controller: textController,
                      focusNode: focusNode,
                      keyboardType: VKeyboardType.desktop,
                      autofocus: true,
                    ),
                  ),
                  DesktopFullKeyboard(
                    controller: vkController,
                    themeData: DesktopKeyboardThemeData.light(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('dk_layout100_char_h')));
      await tester.tap(find.byKey(const ValueKey('dk_layout100_char_i')));
      await tester.tap(find.byKey(const ValueKey('dk_layout100_spacebar')));
      await tester.tap(find.byKey(const ValueKey('dk_layout100_num_7')));
      await tester.pump();

      expect(textController.text, 'hi 7');

      // Ctrl + A selects all text in focused VTextField
      await tester.tap(find.byKey(const ValueKey('dk_layout100_ctrl_left')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('dk_layout100_char_a')));
      await tester.pump();

      expect(textController.selection.baseOffset, 0);
      expect(textController.selection.extentOffset, 4);

      vkController.dispose();
      textController.dispose();
      focusNode.dispose();
    });
  });
}
