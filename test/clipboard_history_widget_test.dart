import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_v_keyboard/flutter_v_keyboard.dart';
import 'package:flutter_v_keyboard/src/widgets/keyboard_key.dart';

Widget _wrap(
  Widget child, {
  VKeyboardController? controller,
  VKeyboardTheme? theme,
  VKeyboardConfig config = const VKeyboardConfig(),
}) =>
    MaterialApp(
      home: VKeyboardScope(
        controller: controller,
        theme: theme,
        config: config,
        child: Scaffold(body: child),
      ),
    );

Finder _switchKey(String label) => find.byWidgetPredicate((w) =>
    w is VirtualKey &&
    w.data.kind == KeyKind.switchLayout &&
    w.data.label == label);

Finder _clipKey() => find.byWidgetPredicate((w) =>
    w is VirtualKey &&
    (w.data.clip == ClipboardIntent.history ||
        w.data.switchTarget == 'clipboard'));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  String clipboardContent = '';

  setUp(() {
    clipboardContent = '';
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform,
            (MethodCall methodCall) async {
      if (methodCall.method == 'Clipboard.setData') {
        clipboardContent =
            (methodCall.arguments as Map)['text']?.toString() ?? '';
        return null;
      }
      if (methodCall.method == 'Clipboard.getData') {
        return <String, dynamic>{'text': clipboardContent};
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group('Clipboard History Text Editing & Security', () {
    testWidgets('pasting at the cursor inserts text correctly', (tester) async {
      final controller = TextEditingController(text: 'Hello world');
      controller.selection = const TextSelection.collapsed(offset: 5);
      final focus = FocusNode();
      final kbController = VKeyboardController();

      await tester.pumpWidget(_wrap(
        VTextField(controller: controller, focusNode: focus),
        controller: kbController,
      ));

      focus.requestFocus();
      await tester.pumpAndSettle();

      kbController.pasteText(' beautiful');
      expect(controller.text, 'Hello beautiful world');
      expect(controller.selection.baseOffset, 15);
    });

    testWidgets('pasting replaces selected text', (tester) async {
      final controller = TextEditingController(text: 'Hello cruel world');
      controller.selection =
          const TextSelection(baseOffset: 6, extentOffset: 11); // "cruel"
      final focus = FocusNode();
      final kbController = VKeyboardController();

      await tester.pumpWidget(_wrap(
        VTextField(controller: controller, focusNode: focus),
        controller: kbController,
      ));

      focus.requestFocus();
      await tester.pumpAndSettle();

      kbController.pasteText('wonderful');
      expect(controller.text, 'Hello wonderful world');
      expect(controller.selection.baseOffset, 15);
    });

    testWidgets('preserves multiline, unicode, and emoji', (tester) async {
      final controller = TextEditingController(text: '');
      final focus = FocusNode();
      final kbController = VKeyboardController();

      await tester.pumpWidget(_wrap(
        VTextField(
          controller: controller,
          focusNode: focus,
          keyboardType: VKeyboardType.multiline,
          maxLines: 4,
        ),
        controller: kbController,
      ));

      focus.requestFocus();
      await tester.pumpAndSettle();

      const multilineSnippet = 'Line 1: 🚀\nLine 2: 日本語 · العربية';
      kbController.pasteText(multilineSnippet);

      expect(controller.text, multilineSnippet);
      expect(controller.selection.baseOffset, multilineSnippet.length);
    });

    testWidgets('respects maxLength and inputFormatters', (tester) async {
      final controller = TextEditingController(text: '123');
      final focus = FocusNode();
      final kbController = VKeyboardController();

      await tester.pumpWidget(_wrap(
        VTextField(
          controller: controller,
          focusNode: focus,
          maxLength: 8,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        controller: kbController,
      ));

      focus.requestFocus();
      await tester.pumpAndSettle();

      // Paste text with non-digits and length exceeding 8
      kbController.pasteText('abc4567890xyz');

      expect(controller.text, '12345678');
      expect(controller.text.length, 8);
    });

    testWidgets('read-only fields are never modified by paste', (tester) async {
      final controller = TextEditingController(text: 'Original Text');
      final focus = FocusNode();
      final kbController = VKeyboardController();

      await tester.pumpWidget(_wrap(
        VTextField(
          controller: controller,
          focusNode: focus,
          readOnly: true,
        ),
        controller: kbController,
      ));

      focus.requestFocus();
      await tester.pumpAndSettle();

      kbController.pasteText('Injected Text');
      expect(controller.text, 'Original Text');
    });

    testWidgets(
        'copy and cut record text with valid selection; sensitive fields are excluded',
        (tester) async {
      final normalController = TextEditingController(text: 'Public Snippet');
      final normalFocus = FocusNode();

      final passwordController =
          TextEditingController(text: 'SecretPassword123');
      final passwordFocus = FocusNode();

      final storage = InMemoryClipboardHistoryStorage();
      final historyManager = ClipboardHistoryManager(storage: storage);
      await historyManager.reload();

      final kbController =
          VKeyboardController(clipboardHistory: historyManager);

      await tester.pumpWidget(_wrap(
        Column(
          children: [
            VTextField(controller: normalController, focusNode: normalFocus),
            VTextField(
              controller: passwordController,
              focusNode: passwordFocus,
              keyboardType: VKeyboardType.password,
              obscureText: true,
            ),
          ],
        ),
        controller: kbController,
      ));

      // 1. Copy from normal field with selection
      normalFocus.requestFocus();
      await tester.pumpAndSettle();
      normalController.selection =
          const TextSelection(baseOffset: 0, extentOffset: 6); // "Public"

      await ClipboardActions.perform(
        ClipboardIntent.copy,
        normalController,
        history: historyManager,
        isSensitive: false,
      );

      expect(historyManager.items.length, 1);
      expect(historyManager.items.first.text, 'Public');

      // 2. Cut from normal field
      normalController.selection =
          const TextSelection(baseOffset: 7, extentOffset: 14); // "Snippet"
      await ClipboardActions.perform(
        ClipboardIntent.cut,
        normalController,
        history: historyManager,
        isSensitive: false,
      );

      expect(normalController.text, 'Public ');
      expect(historyManager.items.length, 2);
      expect(historyManager.items.first.text, 'Snippet');

      // 3. Copy from password/sensitive field -> must NOT record!
      passwordFocus.requestFocus();
      await tester.pumpAndSettle();
      passwordController.selection =
          const TextSelection(baseOffset: 0, extentOffset: 14);

      await ClipboardActions.perform(
        ClipboardIntent.copy,
        passwordController,
        history: historyManager,
        isSensitive: true,
      );

      // Still 2 items, password was ignored!
      expect(historyManager.items.length, 2);
      expect(historyManager.items.any((i) => i.text.contains('SecretPassword')),
          isFalse);
    });

    testWidgets('pasting with missing focus or disposed field does not crash',
        (tester) async {
      final kbController = VKeyboardController();
      await tester.pumpWidget(_wrap(
        const SizedBox(),
        controller: kbController,
      ));

      // No active session
      expect(() => kbController.pasteText('Floating snippet'), returnsNormally);
    });
  });

  group('Clipboard History UI Panel & Interaction', () {
    testWidgets(
        'opens panel, displays items, searches, and pastes item into field',
        (tester) async {
      final controller = TextEditingController(text: 'Initial: ');
      controller.selection = const TextSelection.collapsed(offset: 9);
      final focus = FocusNode();

      final storage = InMemoryClipboardHistoryStorage();
      final historyManager = ClipboardHistoryManager(storage: storage);
      await historyManager.reload();
      await historyManager.record('First snippet');
      await historyManager.record('Second snippet');

      final kbController =
          VKeyboardController(clipboardHistory: historyManager);

      await tester.pumpWidget(_wrap(
        VTextField(controller: controller, focusNode: focus),
        controller: kbController,
      ));

      focus.requestFocus();
      await tester.pumpAndSettle();

      expect(find.byType(KeyboardView), findsOneWidget);
      expect(find.byType(ClipboardHistoryPanel), findsNothing);

      // Open clipboard history panel programmatically or via controller
      kbController.openClipboardHistory();
      await tester.pumpAndSettle();

      expect(find.byType(ClipboardHistoryPanel), findsOneWidget);
      expect(find.text('Clipboard'), findsOneWidget);
      expect(find.text('Second snippet'), findsOneWidget);
      expect(find.text('First snippet'), findsOneWidget);

      // Search functionality
      await tester.enterText(find.byType(TextField).last, 'First');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('First snippet'), findsOneWidget);
      expect(find.text('Second snippet'), findsNothing);

      // Tap the filtered item to paste
      await tester.tap(find.text('First snippet'));
      await tester.pump();

      expect(controller.text, 'Initial: First snippet');
      // Virtual keyboard remains open
      expect(kbController.isVisible, isTrue);

      // Close panel using back button
      await tester.tap(find.byTooltip('Back to keyboard'));
      await tester.pumpAndSettle();

      expect(find.byType(ClipboardHistoryPanel), findsNothing);
      expect(find.byType(KeyboardView), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('pins, unpins, and deletes items from UI', (tester) async {
      final controller = TextEditingController();
      final focus = FocusNode();

      final storage = InMemoryClipboardHistoryStorage();
      final historyManager = ClipboardHistoryManager(storage: storage);
      await historyManager.reload();
      await historyManager.record('Keep Snippet');
      await historyManager.record('Remove Snippet');

      final kbController =
          VKeyboardController(clipboardHistory: historyManager);

      await tester.pumpWidget(_wrap(
        VTextField(controller: controller, focusNode: focus),
        controller: kbController,
      ));

      focus.requestFocus();
      await tester.pumpAndSettle();
      kbController.openClipboardHistory();
      await tester.pumpAndSettle();

      // Pin first item
      final pinButtons = find.byTooltip('Pin item');
      expect(pinButtons, findsWidgets);
      await tester.tap(pinButtons.first);
      await tester.pumpAndSettle();

      expect(historyManager.items.first.isPinned, isTrue);
      expect(find.byTooltip('Unpin item'), findsOneWidget);

      // Delete the second item
      final deleteButtons = find.byTooltip('Delete item');
      await tester.tap(deleteButtons.last);
      await tester.pumpAndSettle();

      expect(historyManager.items.length, 1);
      expect(historyManager.items.first.text, 'Remove Snippet');
    });

    testWidgets('clears unpinned items with confirmation banner',
        (tester) async {
      final controller = TextEditingController();
      final focus = FocusNode();

      final storage = InMemoryClipboardHistoryStorage();
      final historyManager = ClipboardHistoryManager(storage: storage);
      await historyManager.reload();
      await historyManager.record('Pinned Item');
      await historyManager.record('Unpinned Item');
      await historyManager
          .togglePin(historyManager.items.last.id); // Pin "Pinned Item"

      final kbController =
          VKeyboardController(clipboardHistory: historyManager);

      await tester.pumpWidget(_wrap(
        VTextField(controller: controller, focusNode: focus),
        controller: kbController,
      ));

      focus.requestFocus();
      await tester.pumpAndSettle();
      kbController.openClipboardHistory();
      await tester.pumpAndSettle();

      // Tap clear history icon
      await tester.tap(find.byTooltip('Clear history'));
      await tester.pumpAndSettle();

      expect(find.text('Clear unpinned items?'), findsOneWidget);

      // Cancel first
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(historyManager.items.length, 2);

      // Tap clear again and confirm
      await tester.tap(find.byTooltip('Clear history'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(historyManager.items.length, 1);
      expect(historyManager.items.first.text, 'Pinned Item');
    });

    testWidgets('empty state and no-search-results state display correctly',
        (tester) async {
      final controller = TextEditingController();
      final focus = FocusNode();

      final storage = InMemoryClipboardHistoryStorage();
      final historyManager = ClipboardHistoryManager(storage: storage);
      await historyManager.reload();

      final kbController =
          VKeyboardController(clipboardHistory: historyManager);

      await tester.pumpWidget(_wrap(
        VTextField(controller: controller, focusNode: focus),
        controller: kbController,
      ));

      focus.requestFocus();
      await tester.pumpAndSettle();
      kbController.openClipboardHistory();
      await tester.pumpAndSettle();

      expect(find.text('Clipboard is empty'), findsOneWidget);

      // Add one item then search for something not found
      await historyManager.record('Hello world');
      await tester.pumpAndSettle();

      expect(find.text('Hello world'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, 'xyz999');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No matching items'), findsOneWidget);
    });

    testWidgets('opens clipboard history from 123 symbols page key',
        (tester) async {
      final controller = TextEditingController();
      final focus = FocusNode();

      await tester.pumpWidget(_wrap(
        VTextField(
          controller: controller,
          focusNode: focus,
          keyboardType: VKeyboardType.standard,
        ),
      ));

      focus.requestFocus();
      await tester.pumpAndSettle();

      // Switch to 123 layout
      await tester.tap(_switchKey('123'));
      await tester.pumpAndSettle();

      // Find the clipboard key on the 123 page
      expect(_clipKey(), findsOneWidget);
      await tester.tap(_clipKey());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ClipboardHistoryPanel), findsOneWidget);
      expect(find.text('Clipboard'), findsOneWidget);
    });

    testWidgets('renders in light and dark theme without overflows',
        (tester) async {
      final controller = TextEditingController();
      final focus = FocusNode();

      final storage = InMemoryClipboardHistoryStorage();
      final historyManager = ClipboardHistoryManager(storage: storage);
      await historyManager.reload();
      await historyManager.record(
          'A very long text snippet that stretches across multiple lines to verify text overflow truncation in both light and dark themes.');

      final kbController =
          VKeyboardController(clipboardHistory: historyManager);

      // Test Dark Theme
      await tester.pumpWidget(_wrap(
        VTextField(controller: controller, focusNode: focus),
        controller: kbController,
        theme: VKeyboardTheme.dark(),
      ));

      focus.requestFocus();
      await tester.pumpAndSettle();
      kbController.openClipboardHistory();
      await tester.pumpAndSettle();

      expect(find.byType(ClipboardHistoryPanel), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Test Light Theme
      await tester.pumpWidget(_wrap(
        VTextField(controller: controller, focusNode: focus),
        controller: kbController,
        theme: VKeyboardTheme.light(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ClipboardHistoryPanel), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'opening clipboard history automatically synchronizes with system OS clipboard',
        (tester) async {
      // Simulate external copy outside the app into OS clipboard
      clipboardContent = 'External OS snippet';

      final controller = TextEditingController();
      final focus = FocusNode();
      final storage = InMemoryClipboardHistoryStorage();
      final historyManager = ClipboardHistoryManager(storage: storage);
      await historyManager.reload();
      final kbController =
          VKeyboardController(clipboardHistory: historyManager);

      await tester.pumpWidget(_wrap(
        VTextField(controller: controller, focusNode: focus),
        controller: kbController,
      ));

      focus.requestFocus();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Open clipboard history (which triggers sync)
      kbController.openClipboardHistory();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // The external OS snippet should appear in the history panel
      expect(find.text('External OS snippet'), findsOneWidget);

      // Tap the item to paste it into the field
      await tester.tap(find.text('External OS snippet'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(controller.text, 'External OS snippet');
    });

    testWidgets(
        'hardware copy Cmd+C/Ctrl+C populates OS clipboard and clipboard history',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      try {
        final controller = TextEditingController(text: 'Hello from keyboard');
        final focus = FocusNode();
        final storage = InMemoryClipboardHistoryStorage();
        final historyManager = ClipboardHistoryManager(storage: storage);
        await historyManager.reload();
        final kbController =
            VKeyboardController(clipboardHistory: historyManager);

        await tester.pumpWidget(_wrap(
          VTextField(controller: controller, focusNode: focus),
          controller: kbController,
        ));

        focus.requestFocus();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Select 'Hello' explicitly after focus
        controller.selection =
            const TextSelection(baseOffset: 0, extentOffset: 5);
        await tester.pump();

        // Press Meta + C (Cmd + C)
        await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Verify it was copied to system clipboard
        expect(clipboardContent, 'Hello');
        // And recorded in clipboard history
        expect(kbController.clipboardHistory.items.first.text, 'Hello');
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets(
        'clipboard icon key has semantics, tooltip, and icon-only rendering',
        (tester) async {
      final controller = TextEditingController();
      final focus = FocusNode();

      await tester.pumpWidget(_wrap(
        VTextField(
          controller: controller,
          focusNode: focus,
          keyboardType: VKeyboardType.standard,
        ),
      ));

      focus.requestFocus();
      await tester.pumpAndSettle();

      // Switch to 123 layout
      await tester.tap(_switchKey('123'));
      await tester.pumpAndSettle();

      // Find clipboard key
      final clipKeyFinder = _clipKey();
      expect(clipKeyFinder, findsOneWidget);

      final VirtualKey vk = tester.widget(clipKeyFinder);
      expect(vk.data.icon, isNotNull);
      expect(vk.data.label, isNull);

      // Verify semantics label
      expect(find.bySemanticsLabel('Clipboard History'), findsOneWidget);
    });

    testWidgets(
        'desktop keyboard layout renders clipboard icon key and opens history',
        (tester) async {
      final controller = TextEditingController();
      final focus = FocusNode();
      final storage = InMemoryClipboardHistoryStorage();
      final historyManager = ClipboardHistoryManager(storage: storage);
      await historyManager.reload();
      final kbController =
          VKeyboardController(clipboardHistory: historyManager);

      await tester.pumpWidget(_wrap(
        VTextField(
          controller: controller,
          focusNode: focus,
          keyboardType: VKeyboardType.desktop,
        ),
        controller: kbController,
      ));

      focus.requestFocus();
      await tester.pumpAndSettle();

      expect(_clipKey(), findsOneWidget);
      await tester.tap(_clipKey());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ClipboardHistoryPanel), findsOneWidget);
    });
  });
}
