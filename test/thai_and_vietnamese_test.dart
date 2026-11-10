import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_v_keyboard/flutter_v_keyboard.dart';

void main() {
  group('Thai Kedmanee Layout (th_TH)', () {
    test('is registered with correct metadata in VKeyboardLayouts', () {
      final meta = VKeyboardLayouts.getMetadata('th_TH');
      expect(meta, isNotNull);
      expect(meta!.displayName, 'ภาษาไทย');
      expect(meta.shortLabel, 'TH');

      final locale = VKeyboardLocale.fromId('th_TH');
      expect(locale, VKeyboardLocale.thTH);
      expect(locale?.displayName, 'ภาษาไทย');
      expect(locale?.shortLabel, 'TH');
    });

    test('builds Kedmanee layout structure', () {
      final layout = LayoutThTh.build();
      expect(layout.id, 'th_TH');
      expect(layout.pages.containsKey('abc'), isTrue);
      expect(layout.pages.containsKey('123'), isTrue);
      expect(layout.pages.containsKey('symbols'), isTrue);

      final rows = layout.rowsFor('abc');
      expect(rows, isNotNull);
      expect(rows.length, 4);

      // Row 1 has Thai characters
      expect(rows[0].first.text, 'ๆ');
      expect(rows[0].first.shiftText, '๐');
      expect(rows[0].last.text, 'ล');
      expect(rows[0].last.shiftText, 'ฅ');

      // Row 2
      expect(rows[1].first.text, 'ฟ');
      expect(rows[1].first.shiftText, 'ฤ');

      // Row 3
      expect(rows[2][1].text, 'ผ');
      expect(rows[2][1].shiftText, '(');
    });

    test('123 page contains Thai numerals and Baht currency symbol', () {
      final layout = LayoutThTh.build();
      final rows123 = layout.rowsFor('123');

      final topRowSymbols = rows123[0].map((k) => k.text).join();
      expect(topRowSymbols, contains('๑๒๓๔๕'));

      final secondRowSymbols = rows123[1].map((k) => k.text).join();
      expect(secondRowSymbols, contains('฿'));
    });

    test('controller typing in Thai inserts Thai characters with shift support', () {
      final textController = TextEditingController();
      final focusNode = FocusNode();
      final keyboardController = VKeyboardController(
        config: const VKeyboardConfig(
          enabledLocales: [VKeyboardLocale.thTH],
          defaultLocale: VKeyboardLocale.thTH,
          persistLayoutSelection: false,
          enableClipboardHistory: false,
        ),
      );

      final session = KeyboardSession(
        id: 'thai_test_field',
        editingController: textController,
        focusNode: focusNode,
        type: VKeyboardType.standard,
        textInputAction: TextInputAction.done,
        config: keyboardController.config,
        contextRef: () => null,
      );

      keyboardController.attach(session);
      keyboardController.setLayout('th_TH');

      // Type unshifted: 'ส', 'ว', 'ั', 'ส', 'ด', 'ี' -> "สวัสดี"
      final keys = ['ส', 'ว', 'ั', 'ส', 'ด', 'ี'];
      for (final char in keys) {
        keyboardController.handleKey(KeyData.char(char));
      }
      expect(textController.text, 'สวัสดี');

      // Shift tap and type 'ๆ' shifted -> '๐'
      keyboardController.handleShiftTap();
      keyboardController.handleKey(KeyData.char('ๆ', shift: '๐'));
      expect(textController.text, 'สวัสดี๐');

      keyboardController.dispose();
      textController.dispose();
      focusNode.dispose();
    });
  });

  group('Vietnamese Telex Composer (vi_VN)', () {
    test('is registered with correct metadata in VKeyboardLayouts', () {
      final meta = VKeyboardLayouts.getMetadata('vi_VN');
      expect(meta, isNotNull);
      expect(meta!.displayName, 'Tiếng Việt');
      expect(meta.shortLabel, 'VN');

      final locale = VKeyboardLocale.fromId('vi_VN');
      expect(locale, VKeyboardLocale.viVN);
      expect(locale?.displayName, 'Tiếng Việt');
      expect(locale?.shortLabel, 'VN');
    });

    test('transforms diacritic vowels: aa->â, aw->ă, ee->ê, oo->ô, ow->ơ, uw->ư, dd->đ', () {
      var val = const TextEditingValue(text: '');

      // 'aa' -> 'â'
      val = TelexComposer.compose(value: val, char: 'a');
      val = TelexComposer.compose(value: val, char: 'a');
      expect(val.text, 'â');

      // Toggle: 'â' + 'a' -> 'aa'
      val = TelexComposer.compose(value: val, char: 'a');
      expect(val.text, 'aa');

      // 'aw' -> 'ă'
      val = const TextEditingValue(text: 'a');
      val = TelexComposer.compose(value: val, char: 'w');
      expect(val.text, 'ă');

      // 'ee' -> 'ê'
      val = const TextEditingValue(text: 'e');
      val = TelexComposer.compose(value: val, char: 'e');
      expect(val.text, 'ê');

      // 'oo' -> 'ô'
      val = const TextEditingValue(text: 'o');
      val = TelexComposer.compose(value: val, char: 'o');
      expect(val.text, 'ô');

      // 'ow' -> 'ơ'
      val = const TextEditingValue(text: 'o');
      val = TelexComposer.compose(value: val, char: 'w');
      expect(val.text, 'ơ');

      // 'uw' -> 'ư'
      val = const TextEditingValue(text: 'u');
      val = TelexComposer.compose(value: val, char: 'w');
      expect(val.text, 'ư');

      // 'dd' -> 'đ'
      val = const TextEditingValue(text: 'd');
      val = TelexComposer.compose(value: val, char: 'd');
      expect(val.text, 'đ');

      // Toggle: 'đ' + 'd' -> 'dd'
      val = TelexComposer.compose(value: val, char: 'd');
      expect(val.text, 'dd');
    });

    test('transforms compound diphthong uow -> ươ', () {
      var val = const TextEditingValue(text: 'duo');
      val = TelexComposer.compose(value: val, char: 'w');
      expect(val.text, 'dươ');
    });

    test('places tone marks accurately on Vietnamese words', () {
      // 'viêt' + 'j' -> 'việt'
      var val = const TextEditingValue(text: 'viêt');
      val = TelexComposer.compose(value: val, char: 'j');
      expect(val.text, 'việt');

      // 'tiêng' + 's' -> 'tiếng'
      val = const TextEditingValue(text: 'tiêng');
      val = TelexComposer.compose(value: val, char: 's');
      expect(val.text, 'tiếng');

      // 'toan' + 's' -> 'toán'
      val = const TextEditingValue(text: 'toan');
      val = TelexComposer.compose(value: val, char: 's');
      expect(val.text, 'toán');

      // 'dương' + 'f' -> 'dường'
      val = const TextEditingValue(text: 'dương');
      val = TelexComposer.compose(value: val, char: 'f');
      expect(val.text, 'dường');

      // 'cam' + 'r' -> 'cảm'
      val = const TextEditingValue(text: 'cam');
      val = TelexComposer.compose(value: val, char: 'r');
      expect(val.text, 'cảm');

      // 'hoa' + 's' -> 'ho\u00e1'
      val = const TextEditingValue(text: 'hoa');
      val = TelexComposer.compose(value: val, char: 's');
      expect(val.text, 'ho\u00e1');

      // 'z' removes tone mark
      val = TelexComposer.compose(value: val, char: 'z');
      expect(val.text, 'hoa');
    });

    test('preserves casing in Telex composition', () {
      // 'VIÊT' + 'J' -> 'VIỆT'
      var val = const TextEditingValue(text: 'VIÊT');
      val = TelexComposer.compose(value: val, char: 'J');
      expect(val.text, 'VIỆT');

      // 'Viêt' + 'j' -> 'Việt'
      val = const TextEditingValue(text: 'Viêt');
      val = TelexComposer.compose(value: val, char: 'j');
      expect(val.text, 'Việt');

      // 'D' + 'D' -> 'Đ'
      val = const TextEditingValue(text: 'D');
      val = TelexComposer.compose(value: val, char: 'D');
      expect(val.text, 'Đ');
    });

    test('decomposes Vietnamese characters on backspace', () {
      var val = const TextEditingValue(
        text: 'đ',
        selection: TextSelection.collapsed(offset: 1),
      );
      val = TelexComposer.backspace(value: val);
      expect(val.text, 'd');

      val = const TextEditingValue(
        text: 'á',
        selection: TextSelection.collapsed(offset: 1),
      );
      val = TelexComposer.backspace(value: val);
      expect(val.text, 'a');

      val = const TextEditingValue(
        text: 'â',
        selection: TextSelection.collapsed(offset: 1),
      );
      val = TelexComposer.backspace(value: val);
      expect(val.text, 'a');
    });

    test('controller typing in vi_VN performs live Telex composition', () {
      final textController = TextEditingController();
      final focusNode = FocusNode();
      final keyboardController = VKeyboardController(
        config: const VKeyboardConfig(
          enabledLocales: [VKeyboardLocale.viVN],
          defaultLocale: VKeyboardLocale.viVN,
          persistLayoutSelection: false,
          enableClipboardHistory: false,
        ),
      );

      final session = KeyboardSession(
        id: 'vietnam_test_field',
        editingController: textController,
        focusNode: focusNode,
        type: VKeyboardType.standard,
        textInputAction: TextInputAction.done,
        config: keyboardController.config,
        contextRef: () => null,
      );

      keyboardController.attach(session);
      keyboardController.setLayout('vi_VN');

      // Type "v-i-e-e-t-j" -> "Việt" (auto-shift capitalizes first letter)
      for (final char in 'vieetj'.split('')) {
        keyboardController.handleKey(KeyData.char(char));
      }
      expect(textController.text, 'Việt');

      // Space and type "n-a-m" -> "Việt nam"
      keyboardController.handleKey(KeyData.space());
      for (final char in 'nam'.split('')) {
        keyboardController.handleKey(KeyData.char(char));
      }
      expect(textController.text, 'Việt nam');

      keyboardController.dispose();
      textController.dispose();
      focusNode.dispose();
    });
  });
}
