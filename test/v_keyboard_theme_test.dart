import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_v_keyboard/flutter_v_keyboard.dart';

void main() {
  group('VKeyboardTheme presets', () {
    test('light preset exposes stable built-in defaults', () {
      final theme = VKeyboardTheme.light();

      expect(theme.backgroundColor, const Color(0xFFD1D5DB));
      expect(theme.keyColor, Colors.white);
      expect(theme.specialKeyColor, const Color(0xFFADB3BD));
      expect(theme.accentColor, Colors.indigo);
      expect(theme.iconColor, const Color(0xFF1F2937));
    });

    test('dark preset exposes stable built-in defaults', () {
      final theme = VKeyboardTheme.dark();

      expect(theme.backgroundColor, const Color(0xFF1C1C20));
      expect(theme.keyColor, const Color(0xFF3A3A40));
      expect(theme.specialKeyColor, const Color(0xFF2A2A30));
      expect(theme.accentColor, Colors.indigo);
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
  });
}
