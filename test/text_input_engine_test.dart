import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:v_keyboard/v_keyboard.dart';

TextEditingValue v(String text, {int? base, int? extent}) {
  return TextEditingValue(
    text: text,
    selection: TextSelection(
      baseOffset: base ?? text.length,
      extentOffset: extent ?? base ?? text.length,
    ),
  );
}

void main() {
  group('TextInputEngine.insert', () {
    test('inserts at the cursor and advances it', () {
      final r = TextInputEngine.insert(v('helo', base: 3), 'l');
      expect(r.text, 'hello');
      expect(r.selection.baseOffset, 4);
    });

    test('replaces a ranged selection', () {
      final r = TextInputEngine.insert(v('hello', base: 1, extent: 4), 'i');
      expect(r.text, 'hio');
      expect(r.selection.isCollapsed, isTrue);
      expect(r.selection.baseOffset, 2);
    });

    test('appends when selection is invalid', () {
      const value = TextEditingValue(text: 'ab');
      final r = TextInputEngine.insert(value, 'c');
      expect(r.text, 'abc');
      expect(r.selection.baseOffset, 3);
    });
  });

  group('TextInputEngine.deleteBackward', () {
    test('removes the char before a collapsed cursor', () {
      final r = TextInputEngine.deleteBackward(v('hello', base: 5));
      expect(r.text, 'hell');
      expect(r.selection.baseOffset, 4);
    });

    test('removes a ranged selection', () {
      final r = TextInputEngine.deleteBackward(v('hello', base: 1, extent: 4));
      expect(r.text, 'ho');
      expect(r.selection.baseOffset, 1);
    });

    test('is a no-op at offset 0', () {
      final r = TextInputEngine.deleteBackward(v('hi', base: 0));
      expect(r.text, 'hi');
    });

    test('deletes a full emoji (surrogate pair) at once', () {
      final r = TextInputEngine.deleteBackward(v('a😀', base: 3));
      expect(r.text, 'a');
      expect(r.selection.baseOffset, 1);
    });
  });

  group('TextInputEngine.deleteForward / newline / move', () {
    test('deleteForward removes the char after the cursor', () {
      final r = TextInputEngine.deleteForward(v('hello', base: 0));
      expect(r.text, 'ello');
      expect(r.selection.baseOffset, 0);
    });

    test('newline inserts \\n', () {
      final r = TextInputEngine.newline(v('ab', base: 1));
      expect(r.text, 'a\nb');
      expect(r.selection.baseOffset, 2);
    });

    test('moveCursor clamps within bounds', () {
      expect(TextInputEngine.moveCursor(v('abc', base: 1), -5).selection.baseOffset, 0);
      expect(TextInputEngine.moveCursor(v('abc', base: 1), 5).selection.baseOffset, 3);
    });
  });
}
