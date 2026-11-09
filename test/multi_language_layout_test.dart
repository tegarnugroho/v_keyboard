import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_v_keyboard/flutter_v_keyboard.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Multi-language Built-in Layouts', () {
    test('all 9 built-in layouts are registered with metadata', () {
      final expected = [
        'en_US',
        'en_GB',
        'de_DE',
        'fr_FR',
        'es_ES',
        'nordic',
        'tr_TR',
        'ru_RU',
        'el_GR',
      ];

      for (final id in expected) {
        final meta = VKeyboardLayouts.getMetadata(id);
        expect(meta, isNotNull, reason: 'Layout $id should have metadata');
        expect(meta!.displayName, isNotEmpty);
        expect(meta.shortLabel, isNotEmpty);

        final layout = VKeyboardLayouts.getLayout(id);
        expect(layout, isNotNull, reason: 'Layout $id should resolve');
        expect(layout!.pages.containsKey('abc'), isTrue);
        expect(layout.pages.containsKey('123'), isTrue);
        expect(layout.pages.containsKey('symbols'), isTrue);
      }
    });

    test('en_US renders standard QWERTY rows and \$ currency', () {
      final layout = VKeyboardLayouts.getLayout('en_US')!;
      final abcRows = layout.rowsFor('abc');
      expect(abcRows.length, 4);

      final row1 = abcRows[0].map((k) => k.text).join();
      expect(row1, 'qwertyuiop');

      final numRows = layout.rowsFor('123');
      final numRow2 = numRows[1].map((k) => k.text).join();
      expect(numRow2.contains('\$'), isTrue);
    });

    test('en_GB renders QWERTY with £ currency symbol', () {
      final layout = VKeyboardLayouts.getLayout('en_GB')!;
      final numRows = layout.rowsFor('123');
      final numRow2 = numRows[1].map((k) => k.text).join();
      expect(numRow2.contains('£'), isTrue);
    });

    test('de_DE renders QWERTZ with swapped Y/Z, ä, ö, ü, ß and € currency', () {
      final layout = VKeyboardLayouts.getLayout('de_DE')!;
      final abcRows = layout.rowsFor('abc');

      final row1 = abcRows[0].map((k) => k.text).join();
      expect(row1, contains('qwertzuiop'));
      expect(row1, contains('ü'));

      final row2 = abcRows[1].map((k) => k.text).join();
      expect(row2, contains('ö'));
      expect(row2, contains('ä'));

      final row3 = abcRows[2].map((k) => k.text).join();
      expect(row3, contains('yxcvbnm'));
      expect(row3, contains('ß'));

      final numRows = layout.rowsFor('123');
      final numRow2 = numRows[1].map((k) => k.text).join();
      expect(numRow2.contains('€'), isTrue);
    });

    test('fr_FR renders AZERTY with A/Q, Z/W swapped, M on row 2, and accents', () {
      final layout = VKeyboardLayouts.getLayout('fr_FR')!;
      final abcRows = layout.rowsFor('abc');

      final row1 = abcRows[0].map((k) => k.text).join();
      expect(row1, startsWith('azertyuiop'));

      final row2 = abcRows[1].map((k) => k.text).join();
      expect(row2, contains('qsdfghjklm'));
      expect(row2, contains('ù'));

      final row3 = abcRows[2].map((k) => k.text).join();
      expect(row3, contains('wxcvbn'));
      expect(row3, contains('é'));
      expect(row3, contains('è'));
      expect(row3, contains('à'));
      expect(row3, contains('ç'));
    });

    test('es_ES renders QWERTY with ñ, ¿, ¡ and € currency', () {
      final layout = VKeyboardLayouts.getLayout('es_ES')!;
      final abcRows = layout.rowsFor('abc');

      final row2 = abcRows[1].map((k) => k.text).join();
      expect(row2, contains('ñ'));

      final numRows = layout.rowsFor('123');
      final row3 = numRows[2].map((k) => k.text).join();
      expect(row3, contains('¿'));
      expect(row3, contains('¡'));
    });

    test('nordic renders QWERTY with å, ä, ö, æ, ø, and €/kr currency', () {
      final layout = VKeyboardLayouts.getLayout('nordic')!;
      final abcRows = layout.rowsFor('abc');

      final row1 = abcRows[0].map((k) => k.text).join();
      expect(row1, contains('å'));

      final row2 = abcRows[1].map((k) => k.text).join();
      expect(row2, contains('ö'));
      expect(row2, contains('ä'));

      final symRows = layout.rowsFor('symbols');
      final symRow2 = symRows[1].map((k) => k.text).join();
      expect(symRow2, contains('kr'));
    });

    test('tr_TR Turkish Q renders ğ, ü, ş, ı, ö, ç, ₺ currency and dotted/dotless i casing', () {
      final layout = VKeyboardLayouts.getLayout('tr_TR')!;
      final abcRows = layout.rowsFor('abc');

      final row1 = abcRows[0].map((k) => k.text).join();
      expect(row1, contains('ı'));
      expect(row1, contains('ğ'));
      expect(row1, contains('ü'));

      final row2 = abcRows[1].map((k) => k.text).join();
      expect(row2, contains('ş'));
      expect(row2, contains('i'));

      final row3 = abcRows[2].map((k) => k.text).join();
      expect(row3, contains('ö'));
      expect(row3, contains('ç'));

      // Check shift casing on Turkish i and ı:
      final iKey = abcRows[1].firstWhere((k) => k.text == 'i');
      expect(iKey.shiftText, 'İ');
      expect(iKey.resolveLabel(shifted: true), 'İ');
      expect(iKey.resolveText(shifted: true), 'İ');

      final dotlessIKey = abcRows[0].firstWhere((k) => k.text == 'ı');
      expect(dotlessIKey.shiftText, 'I');
      expect(dotlessIKey.resolveLabel(shifted: true), 'I');
      expect(dotlessIKey.resolveText(shifted: true), 'I');

      // Symbol page currency
      final numRows = layout.rowsFor('123');
      final numRow2 = numRows[1].map((k) => k.text).join();
      expect(numRow2, contains('₺'));
    });

    test('ru_RU renders Cyrillic ЙЦУКЕН and ₽ currency', () {
      final layout = VKeyboardLayouts.getLayout('ru_RU')!;
      final abcRows = layout.rowsFor('abc');

      final row1 = abcRows[0].map((k) => k.text).join();
      expect(row1, 'йцукенгшщзхъ');

      final row2 = abcRows[1].map((k) => k.text).join();
      expect(row2, 'фывапролджэ');

      final row3 = abcRows[2].map((k) => k.text).join();
      expect(row3, contains('ячсмитьбюё'));

      final numRows = layout.rowsFor('123');
      final numRow2 = numRows[1].map((k) => k.text).join();
      expect(numRow2, contains('₽'));
    });

    test('el_GR renders Greek alphabet and € currency', () {
      final layout = VKeyboardLayouts.getLayout('el_GR')!;
      final abcRows = layout.rowsFor('abc');

      final row1 = abcRows[0].map((k) => k.text).join();
      expect(row1, contains(';ςερτυθιοπ'));

      final row2 = abcRows[1].map((k) => k.text).join();
      expect(row2, contains('ασδφγηξκλ'));

      final row3 = abcRows[2].map((k) => k.text).join();
      expect(row3, contains('ζχψωβνμ'));
    });
  });

  group('Caps Lock & Non-ASCII isLetter', () {
    test('non-ASCII characters are recognized as letters for Caps Lock', () {
      final chars = ['ä', 'ö', 'ü', 'ß', 'é', 'ñ', 'ğ', 'ı', 'й', 'α'];
      for (final ch in chars) {
        final key = KeyData.char(ch);
        expect(key.isLetter, isTrue, reason: '$ch should be recognized as a letter');
      }

      final nonLetters = ['1', '\$', '.', '-', '@'];
      for (final sym in nonLetters) {
        final key = KeyData.symbol(sym);
        expect(key.isLetter, isFalse, reason: '$sym should not be a letter');
      }
    });

    test('controller isShiftedForKey engages on Caps Lock for non-ASCII letters', () {
      final controller = VKeyboardController();
      controller.modifiers.toggleLock(LockKey.capsLock);

      final germanKey = KeyData.char('ä', shift: 'Ä');
      expect(controller.isShiftedForKey(germanKey), isTrue);

      final turkishKey = KeyData.char('i', shift: 'İ');
      expect(controller.isShiftedForKey(turkishKey), isTrue);

      final digitKey = KeyData.char('1', shift: '!');
      expect(controller.isShiftedForKey(digitKey), isFalse);
    });
  });

  group('Custom Layout Registration', () {
    test('VKeyboardLayouts registers and retrieves custom layouts', () {
      const customId = 'dvorak_custom';
      final customLayout = KeyboardLayout(
        id: customId,
        initialPage: 'abc',
        pages: {
          'abc': [
            ['p', 'y', 'f', 'g'].map((c) => KeyData.char(c)).toList(),
          ],
        },
      );

      VKeyboardLayouts.register(
        customLayout,
        displayName: 'Dvorak Custom',
        shortLabel: 'DV',
      );

      expect(VKeyboardLayouts.registeredIds.contains(customId), isTrue);
      expect(VKeyboardLayouts.getDisplayName(customId), 'Dvorak Custom');
      expect(VKeyboardLayouts.getShortLabel(customId), 'DV');
      expect(VKeyboardLayouts.getLayout(customId), customLayout);
    });

    test('BuiltinLayouts.resolve maps layoutId to locale layouts and keeps numeric pads intact', () {
      // Standard type with Russian layoutId resolves to Russian Cyrillic
      final ruStandard = BuiltinLayouts.resolve(VKeyboardType.standard, layoutId: 'ru_RU');
      final ruRow1 = ruStandard.rowsFor('abc')[0].map((k) => k.text).join();
      expect(ruRow1, contains('йцукен'));

      // German resolves to German QWERTZ
      final deStandard = BuiltinLayouts.resolve(VKeyboardType.standard, layoutId: 'de_DE');
      final deRow1 = deStandard.rowsFor('abc')[0].map((k) => k.text).join();
      expect(deRow1, contains('qwertz'));

      // Numeric and PIN pads remain numeric regardless of active layoutId
      final pinLayout = BuiltinLayouts.resolve(VKeyboardType.pin, layoutId: 'ru_RU');
      final pinRow1 = pinLayout.rowsFor('main')[0].map((k) => k.text).join();
      expect(pinRow1, '123');

      final numberLayout = BuiltinLayouts.resolve(VKeyboardType.number, layoutId: 'de_DE');
      final numRow1 = numberLayout.rowsFor('main')[0].map((k) => k.text).join();
      expect(numRow1, '123');
    });

    test('controller.setLayout updates currentRows to active locale', () {
      final controller = VKeyboardController(
        config: const VKeyboardConfig(
          enabledLayouts: ['en_US', 'ru_RU', 'de_DE'],
          persistLayoutSelection: false,
        ),
      );
      final textController = TextEditingController();
      final focusNode = FocusNode();
      final session = KeyboardSession(
        id: 'test',
        editingController: textController,
        focusNode: focusNode,
        type: VKeyboardType.standard,
        textInputAction: TextInputAction.done,
        config: controller.config,
        contextRef: () => null,
      );

      controller.attach(session);

      // Default is en_US
      final enRow1 = controller.currentRows![0].map((k) => k.text).join();
      expect(enRow1, 'qwertyuiop');

      // Switch to Russian
      controller.setLayout('ru_RU');
      final ruRow1 = controller.currentRows![0].map((k) => k.text).join();
      expect(ruRow1, contains('йцукен'));

      // Switch to German
      controller.setLayout('de_DE');
      final deRow1 = controller.currentRows![0].map((k) => k.text).join();
      expect(deRow1, contains('qwertz'));
    });

    test('VKeyboardLocale enum maps to built-in layouts correctly', () {
      expect(VKeyboardLocale.values.length, 9);
      expect(VKeyboardLocale.enUS.id, 'en_US');
      expect(VKeyboardLocale.deDE.id, 'de_DE');
      expect(VKeyboardLocale.ruRU.id, 'ru_RU');

      expect(VKeyboardLocale.fromId('de_DE'), VKeyboardLocale.deDE);
      expect(VKeyboardLocale.fromId('unknown_id'), isNull);
    });

    test('VKeyboardConfig enabledLocales and defaultLocale support enum configuration', () {
      const config = VKeyboardConfig(
        enabledLocales: [
          VKeyboardLocale.enUS,
          VKeyboardLocale.deDE,
          VKeyboardLocale.ruRU,
        ],
        defaultLocale: VKeyboardLocale.deDE,
      );

      expect(config.enabledLayouts, ['en_US', 'de_DE', 'ru_RU']);
      expect(config.defaultLayout, 'de_DE');
    });

    test('controller setLocale and currentLocale work seamlessly with VKeyboardLocale', () {
      final controller = VKeyboardController(
        config: const VKeyboardConfig(
          enabledLocales: [
            VKeyboardLocale.enUS,
            VKeyboardLocale.deDE,
            VKeyboardLocale.ruRU,
          ],
          persistLayoutSelection: false,
        ),
      );

      expect(controller.currentLocale, VKeyboardLocale.enUS);

      controller.setLocale(VKeyboardLocale.ruRU);
      expect(controller.currentLocale, VKeyboardLocale.ruRU);
      expect(controller.currentLayoutId, 'ru_RU');

      controller.setLocale(VKeyboardLocale.deDE);
      expect(controller.currentLocale, VKeyboardLocale.deDE);
      expect(controller.currentLayoutId, 'de_DE');
    });
  });
}
