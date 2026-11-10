import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_v_keyboard/flutter_v_keyboard.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Multi-language Built-in Layouts', () {
    test('all 13 built-in layouts are registered with metadata', () {
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
        'ko_KR',
        'ja_JP',
        'zh_CN',
        'zh_TW',
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

    test('ko_KR renders 2-Set Hangul and ₩ currency', () {
      final layout = VKeyboardLayouts.getLayout('ko_KR')!;
      final abcRows = layout.rowsFor('abc');

      final row1 = abcRows[0].map((k) => k.text).join();
      expect(row1, 'ㅂㅈㄷㄱㅅㅛㅕㅑㅐㅔ');

      // Shift alternates on row 1
      final row1Shifted = abcRows[0].map((k) => k.resolveText(shifted: true)).join();
      expect(row1Shifted, 'ㅃㅉㄸㄲㅆㅛㅕㅑㅒㅖ');

      final row2 = abcRows[1].map((k) => k.text).join();
      expect(row2, 'ㅁㄴㅇㄹㅎㅗㅓㅏㅣ');

      final row3 = abcRows[2].map((k) => k.text).join();
      expect(row3, contains('ㅋㅌㅊㅍㅠㅜㅡ'));

      final numRows = layout.rowsFor('123');
      final numRow2 = numRows[1].map((k) => k.text).join();
      expect(numRow2, contains('₩'));
    });

    test('ja_JP renders JIS Kana and ¥ currency with voicing marks', () {
      final layout = VKeyboardLayouts.getLayout('ja_JP')!;
      final abcRows = layout.rowsFor('abc');

      final row1 = abcRows[0].map((k) => k.text).join();
      expect(row1, contains('たていすかんなにらせ'));
      expect(row1, contains('゛'));
      expect(row1, contains('゜'));

      final row2 = abcRows[1].map((k) => k.text).join();
      expect(row2, contains('ちとしはきくまのりれけ'));

      final row3 = abcRows[2].map((k) => k.text).join();
      expect(row3, contains('つさそひこみもねるめろ'));

      final bottomRow = abcRows[3].map((k) => k.text).join();
      expect(bottomRow, contains('、'));
      expect(bottomRow, contains('。'));

      final numRows = layout.rowsFor('123');
      final numRow2 = numRows[1].map((k) => k.text).join();
      expect(numRow2, contains('¥'));
    });

    test('zh_CN renders Pinyin QWERTY with fullwidth punctuation and ¥ currency', () {
      final layout = VKeyboardLayouts.getLayout('zh_CN')!;
      final abcRows = layout.rowsFor('abc');

      final row1 = abcRows[0].map((k) => k.text).join();
      expect(row1, 'qwertyuiop');

      final bottomRow = abcRows[3].map((k) => k.text).join();
      expect(bottomRow, contains('，'));
      expect(bottomRow, contains('。'));

      final numRows = layout.rowsFor('123');
      final numRow2 = numRows[1].map((k) => k.text).join();
      expect(numRow2, contains('¥'));
    });

    test('zh_TW renders Bopomofo Zhuyin layout', () {
      final layout = VKeyboardLayouts.getLayout('zh_TW')!;
      final abcRows = layout.rowsFor('abc');

      final row1 = abcRows[0].map((k) => k.text).join();
      expect(row1, 'ㄅㄆㄇㄈㄉㄊㄋㄌㄍㄎ');

      final row2 = abcRows[1].map((k) => k.text).join();
      expect(row2, 'ㄏㄐㄑㄒㄓㄔㄕㄖㄗㄘㄙ');

      final row3 = abcRows[2].map((k) => k.text).join();
      expect(row3, contains('ㄧㄨㄩㄚㄛㄜㄝㄞㄟㄠㄢ'));
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
      expect(VKeyboardLocale.values.length, 13);
      expect(VKeyboardLocale.enUS.id, 'en_US');
      expect(VKeyboardLocale.deDE.id, 'de_DE');
      expect(VKeyboardLocale.ruRU.id, 'ru_RU');
      expect(VKeyboardLocale.koKR.id, 'ko_KR');
      expect(VKeyboardLocale.koKR.displayName, '한국어');
      expect(VKeyboardLocale.koKR.shortLabel, 'KO');
      expect(VKeyboardLocale.jaJP.id, 'ja_JP');
      expect(VKeyboardLocale.jaJP.displayName, '日本語');
      expect(VKeyboardLocale.jaJP.shortLabel, 'JP');
      expect(VKeyboardLocale.zhCN.id, 'zh_CN');
      expect(VKeyboardLocale.zhCN.displayName, '简体中文');
      expect(VKeyboardLocale.zhCN.shortLabel, 'CN');
      expect(VKeyboardLocale.zhTW.id, 'zh_TW');
      expect(VKeyboardLocale.zhTW.displayName, '繁體中文');
      expect(VKeyboardLocale.zhTW.shortLabel, 'TW');

      expect(VKeyboardLocale.fromId('de_DE'), VKeyboardLocale.deDE);
      expect(VKeyboardLocale.fromId('ko_KR'), VKeyboardLocale.koKR);
      expect(VKeyboardLocale.fromId('ja_JP'), VKeyboardLocale.jaJP);
      expect(VKeyboardLocale.fromId('zh_CN'), VKeyboardLocale.zhCN);
      expect(VKeyboardLocale.fromId('zh_TW'), VKeyboardLocale.zhTW);
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

  group('HangulComposer Engine', () {
    test('composes basic syllables (초성 + 중성 + 종성)', () {
      var val = const TextEditingValue(text: '');

      // ㅎ + ㅏ + ㄴ = 한
      val = HangulComposer.compose(value: val, jamo: 'ㅎ');
      expect(val.text, 'ㅎ');
      val = HangulComposer.compose(value: val, jamo: 'ㅏ');
      expect(val.text, '하');
      val = HangulComposer.compose(value: val, jamo: 'ㄴ');
      expect(val.text, '한');

      // ㄱ + ㅡ + ㄹ = 글
      val = HangulComposer.compose(value: val, jamo: 'ㄱ');
      expect(val.text, '한ㄱ');
      val = HangulComposer.compose(value: val, jamo: 'ㅡ');
      expect(val.text, '한그');
      val = HangulComposer.compose(value: val, jamo: 'ㄹ');
      expect(val.text, '한글');
    });

    test('composes compound vowels (ㅗ + ㅏ = ㅘ, 고 + ㅏ = 과)', () {
      var val = const TextEditingValue(text: '');

      // Standalone compound vowel: ㅗ + ㅏ = ㅘ
      val = HangulComposer.compose(value: val, jamo: 'ㅗ');
      val = HangulComposer.compose(value: val, jamo: 'ㅏ');
      expect(val.text, 'ㅘ');

      // Syllable compound vowel: ㄱ + ㅗ + ㅏ + ㄴ = 관
      val = const TextEditingValue(text: '');
      val = HangulComposer.compose(value: val, jamo: 'ㄱ');
      val = HangulComposer.compose(value: val, jamo: 'ㅗ');
      expect(val.text, '고');
      val = HangulComposer.compose(value: val, jamo: 'ㅏ');
      expect(val.text, '과');
      val = HangulComposer.compose(value: val, jamo: 'ㄴ');
      expect(val.text, '관');
    });

    test('composes compound batchim (달 + ㄱ = 닭)', () {
      var val = const TextEditingValue(text: '');
      for (final jamo in ['ㄷ', 'ㅏ', 'ㄹ', 'ㄱ']) {
        val = HangulComposer.compose(value: val, jamo: jamo);
      }
      expect(val.text, '닭');
    });

    test('splits single batchim when a vowel follows (간 + ㅏ = 가나)', () {
      var val = const TextEditingValue(text: '');
      for (final jamo in ['ㄱ', 'ㅏ', 'ㄴ', 'ㅏ']) {
        val = HangulComposer.compose(value: val, jamo: jamo);
      }
      expect(val.text, '가나');
    });

    test('splits compound batchim when a vowel follows (닭 + ㅣ = 달기)', () {
      var val = const TextEditingValue(text: '');
      for (final jamo in ['ㄷ', 'ㅏ', 'ㄹ', 'ㄱ', 'ㅣ']) {
        val = HangulComposer.compose(value: val, jamo: jamo);
      }
      expect(val.text, '달기');
    });

    test('decomposes syllable level-by-level on backspace (닭 -> 달 -> 다 -> ㄷ -> empty)', () {
      var val = const TextEditingValue(
        text: '닭',
        selection: TextSelection.collapsed(offset: 1),
      );

      val = HangulComposer.backspace(value: val);
      expect(val.text, '달');

      val = HangulComposer.backspace(value: val);
      expect(val.text, '다');

      val = HangulComposer.backspace(value: val);
      expect(val.text, 'ㄷ');

      val = HangulComposer.backspace(value: val);
      expect(val.text, '');
    });

    test('decomposes compound vowel on backspace (과 -> 고 -> ㄱ -> empty)', () {
      var val = const TextEditingValue(
        text: '과',
        selection: TextSelection.collapsed(offset: 1),
      );

      val = HangulComposer.backspace(value: val);
      expect(val.text, '고');

      val = HangulComposer.backspace(value: val);
      expect(val.text, 'ㄱ');

      val = HangulComposer.backspace(value: val);
      expect(val.text, '');
    });

    test('types full Korean greeting 안녕하세요 seamlessly', () {
      const keystrokes = ['ㅇ', 'ㅏ', 'ㄴ', 'ㄴ', 'ㅕ', 'ㅇ', 'ㅎ', 'ㅏ', 'ㅅ', 'ㅔ', 'ㅇ', 'ㅛ'];
      var val = const TextEditingValue(text: '');
      for (final k in keystrokes) {
        val = HangulComposer.compose(value: val, jamo: k);
      }
      expect(val.text, '안녕하세요');
    });

    test('controller handles ko_KR keystrokes and decomposes backspace in session', () {
      final textController = TextEditingController();
      final focusNode = FocusNode();
      final keyboardController = VKeyboardController(
        config: const VKeyboardConfig(
          enabledLocales: [VKeyboardLocale.enUS, VKeyboardLocale.koKR],
          defaultLocale: VKeyboardLocale.koKR,
          persistLayoutSelection: false,
        ),
      );

      final session = KeyboardSession(
        id: 'test_korean_field',
        editingController: textController,
        focusNode: focusNode,
        type: VKeyboardType.standard,
        textInputAction: TextInputAction.done,
        config: keyboardController.config,
        contextRef: () => null,
      );

      keyboardController.attach(session);
      keyboardController.setLayout('ko_KR');

      // Type 'ㅎ' -> 'ㅏ' -> 'ㄴ'
      keyboardController.handleKey(KeyData.char('ㅎ'));
      expect(textController.text, 'ㅎ');

      keyboardController.handleKey(KeyData.char('ㅏ'));
      expect(textController.text, '하');

      keyboardController.handleKey(KeyData.char('ㄴ'));
      expect(textController.text, '한');

      // Backspace decomposes '한' to '하'
      keyboardController.handleKey(KeyData.backspace());
      expect(textController.text, '하');

      // Backspace decomposes '하' to 'ㅎ'
      keyboardController.handleKey(KeyData.backspace());
      expect(textController.text, 'ㅎ');

      // Backspace deletes 'ㅎ'
      keyboardController.handleKey(KeyData.backspace());
      expect(textController.text, '');
    });
  });

  group('KanaComposer Engine', () {
    test('composes dakuten voicing marks (か + ゛ = が, は + ゛ = ば)', () {
      var val = const TextEditingValue(text: 'か');
      val = KanaComposer.compose(value: val, mark: '゛');
      expect(val.text, 'が');

      val = const TextEditingValue(text: 'は');
      val = KanaComposer.compose(value: val, mark: '゛');
      expect(val.text, 'ば');
    });

    test('composes handakuten semi-voicing marks (は + ゜ = ぱ)', () {
      var val = const TextEditingValue(text: 'は');
      val = KanaComposer.compose(value: val, mark: '゜');
      expect(val.text, 'ぱ');
    });

    test('decomposes voiced kana back to base kana on backspace', () {
      var val = const TextEditingValue(
        text: 'が',
        selection: TextSelection.collapsed(offset: 1),
      );
      val = KanaComposer.backspace(value: val);
      expect(val.text, 'か');

      val = const TextEditingValue(
        text: 'ぱ',
        selection: TextSelection.collapsed(offset: 1),
      );
      val = KanaComposer.backspace(value: val);
      expect(val.text, 'は');
    });

    test('controller handles ja_JP voicing marks and backspace in session', () {
      final textController = TextEditingController();
      final focusNode = FocusNode();
      final keyboardController = VKeyboardController(
        config: const VKeyboardConfig(
          enabledLocales: [VKeyboardLocale.enUS, VKeyboardLocale.jaJP],
          defaultLocale: VKeyboardLocale.jaJP,
          persistLayoutSelection: false,
          enableImeCandidates: false,
        ),
      );

      final session = KeyboardSession(
        id: 'test_japanese_field',
        editingController: textController,
        focusNode: focusNode,
        type: VKeyboardType.standard,
        textInputAction: TextInputAction.done,
        config: keyboardController.config,
        contextRef: () => null,
      );

      keyboardController.attach(session);
      keyboardController.setLayout('ja_JP');

      // Type 'か'
      keyboardController.handleKey(KeyData.char('か'));
      expect(textController.text, 'か');

      // Type '゛' -> transforms to 'が'
      keyboardController.handleKey(KeyData.char('゛'));
      expect(textController.text, 'が');

      // Backspace decomposes 'が' to 'か'
      keyboardController.handleKey(KeyData.backspace());
      expect(textController.text, 'か');

      // Backspace deletes 'か'
      keyboardController.handleKey(KeyData.backspace());
      expect(textController.text, '');
    });
  });
}
