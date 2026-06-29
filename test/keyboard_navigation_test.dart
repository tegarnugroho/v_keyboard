import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_v_keyboard/flutter_v_keyboard.dart';

TextEditingValue v(String text, {int? base, int? extent}) => TextEditingValue(
      text: text,
      selection: TextSelection(
        baseOffset: base ?? text.length,
        extentOffset: extent ?? base ?? text.length,
      ),
    );

void main() {
  group('KeyboardNavigation horizontal', () {
    test('char left/right moves one', () {
      final r = KeyboardNavigation.move(v('abc', base: 1), NavIntent.right,
          extend: false, word: false);
      expect(r.selection.baseOffset, 2);
    });

    test('word right jumps to end of word', () {
      final r = KeyboardNavigation.move(v('hello world', base: 0),
          NavIntent.right,
          extend: false, word: true);
      expect(r.selection.baseOffset, 5);
    });

    test('shift+right extends selection', () {
      final r = KeyboardNavigation.move(v('abc', base: 0), NavIntent.right,
          extend: true, word: false);
      expect(r.selection.baseOffset, 0);
      expect(r.selection.extentOffset, 1);
    });

    test('bare right collapses a range to its end', () {
      final r = KeyboardNavigation.move(v('abcde', base: 1, extent: 4),
          NavIntent.right,
          extend: false, word: false);
      expect(r.selection.isCollapsed, isTrue);
      expect(r.selection.baseOffset, 4);
    });
  });

  group('KeyboardNavigation line/vertical', () {
    test('home / end go to line edges', () {
      final home = KeyboardNavigation.move(v('ab\ncd', base: 4), NavIntent.home,
          extend: false, word: false);
      expect(home.selection.baseOffset, 3);
      final end = KeyboardNavigation.move(v('ab\ncd', base: 3), NavIntent.end,
          extend: false, word: false);
      expect(end.selection.baseOffset, 5);
    });

    test('ctrl+home goes to document start', () {
      final r = KeyboardNavigation.move(v('ab\ncd', base: 4), NavIntent.home,
          extend: false, word: true);
      expect(r.selection.baseOffset, 0);
    });

    test('down preserves column', () {
      // 'abc\ndefgh', cursor at column 2 of line 0 (offset 2) -> line 1 col 2.
      final r = KeyboardNavigation.move(v('abc\ndefgh', base: 2), NavIntent.down,
          extend: false, word: false);
      expect(r.selection.baseOffset, 6); // 4 (line start) + 2
    });

    test('up from first line clamps to start', () {
      final r = KeyboardNavigation.move(v('abc\ndef', base: 2), NavIntent.up,
          extend: false, word: false);
      expect(r.selection.baseOffset, 0);
    });
  });
}
