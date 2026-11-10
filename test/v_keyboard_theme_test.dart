import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_v_keyboard/flutter_v_keyboard.dart';
import 'package:flutter_v_keyboard/src/widgets/keyboard_key.dart';

void main() {
  group('VKeyboardTheme presets', () {
    test('light preset exposes stable built-in defaults', () {
      final theme = VKeyboardTheme.light();

      expect(theme.backgroundColor, const Color(0xFFD1D5DB));
      expect(theme.keyColor, Colors.white);
      expect(theme.specialKeyColor, const Color(0xFFADB3BD));
      expect(theme.accentColor, Colors.indigo);
      expect(theme.activeKeyColor, Colors.indigo);
      expect(theme.activeForegroundColor, Colors.white);
      expect(theme.iconColor, const Color(0xFF1F2937));
    });

    test('dark preset exposes stable built-in defaults', () {
      final theme = VKeyboardTheme.dark();

      expect(theme.backgroundColor, const Color(0xFF1C1C20));
      expect(theme.keyColor, const Color(0xFF3A3A40));
      expect(theme.specialKeyColor, const Color(0xFF2A2A30));
      expect(theme.accentColor, Colors.indigo);
      expect(theme.activeKeyColor, Colors.indigo);
      expect(theme.activeForegroundColor, Colors.white);
      expect(theme.iconColor, Colors.white);
    });

    test('fromTheme keeps using ambient color scheme values', () {
      final theme = VKeyboardTheme.fromTheme(ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Colors.teal,
          onSurface: Colors.amber,
        ),
      ));

      expect(theme.accentColor, Colors.teal);
      expect(theme.iconColor, Colors.amber);
      expect(theme.textStyle.color, Colors.amber);
    });

    testWidgets('engaged shift key uses activeKeyColor and activeForegroundColor in dark mode', (tester) async {
      final theme = VKeyboardTheme.dark(accentColor: const Color(0xFF2563EB));
      final controller = VKeyboardController();
      final textController = TextEditingController();
      final focusNode = FocusNode();

      final session = KeyboardSession(
        id: 'test_field',
        editingController: textController,
        focusNode: focusNode,
        type: VKeyboardType.standard,
        textInputAction: TextInputAction.done,
        config: controller.config,
        contextRef: () => null,
      );

      controller.attach(session);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 80,
                child: Row(
                  children: [
                    VirtualKey(
                      data: KeyData.shift(),
                      controller: controller,
                      theme: theme,
                      height: 48,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // In standard layout when attached to empty field, shift is armed (engaged)
      expect(controller.isShiftActive, isTrue);

      final materialFinder = find.descendant(
        of: find.byType(VirtualKey),
        matching: find.byType(Material),
      );
      expect(materialFinder, findsOneWidget);
      final materialWidget = tester.widget<Material>(materialFinder);
      expect(materialWidget.color, theme.activeKeyColor);

      final iconFinder = find.byType(Icon);
      expect(iconFinder, findsOneWidget);
      final iconWidget = tester.widget<Icon>(iconFinder);
      expect(iconWidget.color, theme.activeForegroundColor);
      expect(iconWidget.color, Colors.white);

      controller.dispose();
      textController.dispose();
      focusNode.dispose();
    });
  });
}
