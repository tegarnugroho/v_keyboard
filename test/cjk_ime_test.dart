import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_v_keyboard/flutter_v_keyboard.dart';

void main() {
  group('PinyinImeEngine (zh_CN)', () {
    const engine = PinyinImeEngine();

    test('validates and normalizes Pinyin characters', () {
      expect(engine.isValidInput('a'), isTrue);
      expect(engine.isValidInput('Z'), isTrue);
      expect(engine.isValidInput("'"), isTrue);
      expect(engine.isValidInput('1'), isFalse);
      expect(engine.isValidInput('，'), isFalse);
      expect(engine.isValidInput(' '), isFalse);

      expect(engine.normalizeInput('N'), 'n');
      expect(engine.normalizeInput('H'), 'h');
    });

    test('retrieves exact phrases', () {
      final candidates = engine.getCandidates('nihao');
      expect(candidates, contains('你好'));
    });

    test('retrieves exact syllables', () {
      final candidates = engine.getCandidates('wo');
      expect(candidates, contains('我'));
    });

    test('retrieves candidates by prefix match', () {
      final candidates = engine.getCandidates('nih');
      expect(candidates, contains('你好'));
    });

    test('segments multi-syllable inputs greedily', () {
      final candidates = engine.getCandidates('wode');
      expect(candidates, contains('我的'));
    });
  });

  group('ZhuyinImeEngine (zh_TW)', () {
    const engine = ZhuyinImeEngine();

    test('validates Zhuyin characters and tone marks', () {
      expect(engine.isValidInput('ㄋ'), isTrue);
      expect(engine.isValidInput('ㄧ'), isTrue);
      expect(engine.isValidInput('ˊ'), isTrue);
      expect(engine.isValidInput('a'), isFalse);
      expect(engine.isValidInput('1'), isFalse);
    });

    test('retrieves exact Zhuyin phrases', () {
      final candidates = engine.getCandidates('ㄋㄧㄏㄠ');
      expect(candidates, contains('你好'));
    });

    test('retrieves exact Zhuyin syllables', () {
      final candidates = engine.getCandidates('ㄋㄧ');
      expect(candidates, contains('你'));
    });

    test('retrieves Zhuyin candidates by prefix match', () {
      final candidates = engine.getCandidates('ㄋㄧㄏ');
      expect(candidates, contains('你好'));
    });
  });

  group('JapaneseImeEngine (ja_JP)', () {
    const engine = JapaneseImeEngine();

    test('validates Hiragana and Katakana characters', () {
      expect(engine.isValidInput('に'), isTrue);
      expect(engine.isValidInput('ニ'), isTrue);
      expect(engine.isValidInput('゛'), isTrue);
      expect(engine.isValidInput('a'), isFalse);
      expect(engine.isValidInput('1'), isFalse);
    });

    test('converts Hiragana to Katakana algorithmically', () {
      expect(JapaneseImeEngine.toKatakana('にほん'), 'ニホン');
      expect(JapaneseImeEngine.toKatakana('とうきょう'), 'トウキョウ');
      expect(JapaneseImeEngine.toKatakana('ありがとう'), 'アリガトウ');
    });

    test('retrieves Kanji, Hiragana, and Katakana candidates', () {
      final candidates = engine.getCandidates('にほん');
      expect(candidates, contains('日本'));
      expect(candidates, contains('にほん'));
      expect(candidates, contains('ニホン'));
    });

    test('retrieves Kanji candidates by prefix match', () {
      final candidates = engine.getCandidates('とう');
      expect(candidates, contains('東京'));
    });
  });

  group('VKeyboardController IME Workflow', () {
    late TextEditingController textController;
    late FocusNode focusNode;
    late VKeyboardController keyboardController;
    late KeyboardSession session;

    setUp(() {
      textController = TextEditingController();
      focusNode = FocusNode();
      keyboardController = VKeyboardController(
        config: const VKeyboardConfig(
          enabledLocales: [
            VKeyboardLocale.enUS,
            VKeyboardLocale.zhCN,
            VKeyboardLocale.zhTW,
            VKeyboardLocale.jaJP,
          ],
          defaultLocale: VKeyboardLocale.zhCN,
          persistLayoutSelection: false,
          enableImeCandidates: true,
          enableClipboardHistory: false,
        ),
      );

      session = KeyboardSession(
        id: 'test_cjk_field',
        editingController: textController,
        focusNode: focusNode,
        type: VKeyboardType.standard,
        textInputAction: TextInputAction.done,
        config: keyboardController.config,
        contextRef: () => null,
      );

      keyboardController.attach(session);
    });

    tearDown(() {
      keyboardController.dispose();
      textController.dispose();
      focusNode.dispose();
    });

    test('Pinyin typing: buffers composing text and space commits candidate', () {
      keyboardController.setLayout('zh_CN');

      // Type "nihao"
      for (final char in 'nihao'.split('')) {
        keyboardController.handleKey(KeyData.char(char));
      }

      expect(keyboardController.composingText, 'nihao');
      expect(keyboardController.hasCandidates, isTrue);
      expect(keyboardController.candidates, contains('你好'));
      expect(textController.text, ''); // Field is untouched during composing

      // Space commits first candidate ('你好')
      keyboardController.handleKey(KeyData.space());
      expect(textController.text, '你好');
      expect(keyboardController.composingText, '');
      expect(keyboardController.candidates, isEmpty);
    });

    test('Pinyin typing: Enter commits raw composing string', () {
      keyboardController.setLayout('zh_CN');

      for (final char in 'test'.split('')) {
        keyboardController.handleKey(KeyData.char(char));
      }

      expect(keyboardController.composingText, 'test');
      keyboardController.handleKey(KeyData.enter());

      expect(textController.text, 'test');
      expect(keyboardController.composingText, '');
      expect(keyboardController.candidates, isEmpty);
    });

    test('Pinyin typing: Backspace deletes composing characters', () {
      keyboardController.setLayout('zh_CN');

      keyboardController.handleKey(KeyData.char('n'));
      keyboardController.handleKey(KeyData.char('i'));
      expect(keyboardController.composingText, 'ni');

      keyboardController.handleKey(KeyData.backspace());
      expect(keyboardController.composingText, 'n');
      expect(textController.text, '');

      keyboardController.handleKey(KeyData.backspace());
      expect(keyboardController.composingText, '');
      expect(textController.text, '');
    });

    test('Zhuyin typing: buffers Zhuyin and commits candidate', () {
      keyboardController.setLayout('zh_TW');

      for (final char in 'ㄋㄧㄏㄠ'.split('')) {
        keyboardController.handleKey(KeyData.char(char));
      }

      expect(keyboardController.composingText, 'ㄋㄧㄏㄠ');
      expect(keyboardController.candidates, contains('你好'));
      expect(textController.text, '');

      keyboardController.commitCandidate('你好');
      expect(textController.text, '你好');
      expect(keyboardController.composingText, '');
    });

    test('Japanese typing: handles voicing mark in composing buffer and commits', () {
      keyboardController.setLayout('ja_JP');

      keyboardController.handleKey(KeyData.char('に'));
      keyboardController.handleKey(KeyData.char('ほ'));
      keyboardController.handleKey(KeyData.char('ん'));

      expect(keyboardController.composingText, 'にほん');
      expect(keyboardController.candidates, contains('日本'));

      // Voicing mark test: type 'は' then '゛' -> 'ば'
      keyboardController.clearComposing();
      keyboardController.handleKey(KeyData.char('は'));
      expect(keyboardController.composingText, 'は');

      keyboardController.handleKey(KeyData.char('゛'));
      expect(keyboardController.composingText, 'ば');

      // Commit 'ば'
      keyboardController.handleKey(KeyData.space());
      expect(textController.text, 'ば');
    });

    test('Typing punctuation while composing commits candidate first', () {
      keyboardController.setLayout('zh_CN');

      for (final char in 'nihao'.split('')) {
        keyboardController.handleKey(KeyData.char(char));
      }
      expect(keyboardController.composingText, 'nihao');

      // Type comma punctuation '，'
      keyboardController.handleKey(KeyData.char('，'));

      // First candidate '你好' was committed, followed by '，'
      expect(textController.text, '你好，');
      expect(keyboardController.composingText, '');
    });

    test('Switching layout or detaching resets active composing buffer', () {
      keyboardController.setLayout('zh_CN');
      keyboardController.handleKey(KeyData.char('n'));
      keyboardController.handleKey(KeyData.char('i'));
      expect(keyboardController.composingText, 'ni');

      keyboardController.setLayout('en_US');
      expect(keyboardController.composingText, '');
      expect(keyboardController.candidates, isEmpty);
    });
  });

  group('CandidateBar Widget', () {
    testWidgets('renders candidates and handles selection taps', (tester) async {
      final textController = TextEditingController();
      final focusNode = FocusNode();
      final controller = VKeyboardController(
        config: const VKeyboardConfig(
          enabledLocales: [VKeyboardLocale.zhCN],
          defaultLocale: VKeyboardLocale.zhCN,
          persistLayoutSelection: false,
          enableClipboardHistory: false,
        ),
      );

      final session = KeyboardSession(
        id: 'test_candidate_bar_field',
        editingController: textController,
        focusNode: focusNode,
        type: VKeyboardType.standard,
        textInputAction: TextInputAction.done,
        config: controller.config,
        contextRef: () => null,
      );

      controller.attach(session);
      controller.setLayout('zh_CN');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CandidateBar(
              controller: controller,
              theme: VKeyboardTheme.light(),
            ),
          ),
        ),
      );

      // Initially empty (SizedBox.shrink)
      expect(find.byType(ListView), findsNothing);

      // Type "nihao"
      for (final char in 'nihao'.split('')) {
        controller.handleKey(KeyData.char(char));
      }
      await tester.pumpAndSettle();

      // Composing preview and candidate chips should appear
      expect(find.text('nihao'), findsOneWidget);
      expect(find.text('1. 你好'), findsOneWidget);

      // Tap the candidate chip
      await tester.tap(find.text('1. 你好'));
      await tester.pumpAndSettle();

      expect(textController.text, '你好');
      expect(find.text('nihao'), findsNothing);

      controller.dispose();
      textController.dispose();
      focusNode.dispose();
    });
  });
}
