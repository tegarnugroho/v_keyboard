import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_v_keyboard/flutter_v_keyboard.dart';

void main() {
  testWidgets('desktopFormFactor renders DesktopFullKeyboard and types',
      (tester) async {
    tester.view.physicalSize = const Size(1470, 956);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final text = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => VKeyboardScope(
          config: const VKeyboardConfig(
            desktopFormFactor: KeyboardLayoutType.layout60,
            persistLayoutSelection: false,
            enableClipboardHistory: false,
            syncSystemClipboard: false,
          ),
          child: child!,
        ),
        home: Scaffold(
          body: VTextField(
            controller: text,
            keyboardType: VKeyboardType.desktop,
          ),
        ),
      ),
    );
    await tester.tap(find.byType(VTextField));
    await tester.pumpAndSettle();

    expect(find.byType(DesktopFullKeyboard), findsOneWidget);
    expect(find.byType(KeyboardView), findsNothing);
    // 60%: no function row.
    expect(find.text('F1'), findsNothing);

    final box =
        tester.renderObject<RenderBox>(find.byType(DesktopFullKeyboard));
    expect(box.size.width, closeTo(1470, 0.5));

    await tester.tap(find.text('q').last);
    await tester.tap(find.text('w').last);
    await tester.pumpAndSettle();
    expect(text.text, 'qw');

    // Keys must get Material text defaults even though the scope sits above
    // the Navigator (no yellow-underline fallback style).
    final keyText = tester.widget<Text>(find.text('q').last);
    final style = DefaultTextStyle.of(tester.element(find.text('q').last));
    expect(keyText.style?.decoration ?? style.style.decoration,
        isNot(TextDecoration.underline));
    expect(style.style.decoration, isNot(TextDecoration.underline));

    // Down-arrow close button renders like non-desktop KeyboardView and hides
    // the desktop keyboard when tapped.
    final closeFinder = find.byIcon(Icons.keyboard_arrow_down_rounded);
    expect(closeFinder, findsOneWidget);
    expect(find.bySemanticsLabel('Close keyboard'), findsOneWidget);

    await tester.tap(closeFinder);
    await tester.pumpAndSettle();
    expect(find.byType(DesktopFullKeyboard), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'desktopFormFactor bottom utility bar supports clipboard button and respects showHideKeyboardButton: false',
      (tester) async {
    tester.view.physicalSize = const Size(1470, 956);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final text = TextEditingController();
    final kbController = VKeyboardController(
      config: const VKeyboardConfig(
        desktopFormFactor: KeyboardLayoutType.layout100,
        showHideKeyboardButton: false,
        enableClipboardHistory: true,
        showClipboardButton: true,
        syncSystemClipboard: false,
        persistLayoutSelection: false,
      ),
      clipboardHistory: ClipboardHistoryManager(
        storage: InMemoryClipboardHistoryStorage(),
        syncSystemClipboard: false,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => VKeyboardScope(
          controller: kbController,
          config: kbController.config,
          child: child!,
        ),
        home: Scaffold(
          body: VTextField(
            controller: text,
            keyboardType: VKeyboardType.desktop,
          ),
        ),
      ),
    );
    await tester.tap(find.byType(VTextField));
    await tester.pumpAndSettle();

    expect(find.byType(DesktopFullKeyboard), findsOneWidget);
    expect(find.bySemanticsLabel('Close keyboard'), findsNothing);
    expect(
      find.byKey(const ValueKey('dk_bottom_bar_clipboard')),
      findsOneWidget,
    );

    // Tapping bottom-right clipboard opens ClipboardHistoryPanel cleanly.
    await tester.tap(find.byKey(const ValueKey('dk_bottom_bar_clipboard')));
    await tester.pumpAndSettle();
    expect(find.byType(ClipboardHistoryPanel), findsOneWidget);
    expect(tester.takeException(), isNull);

    kbController.dispose();
    text.dispose();
  });

  testWidgets(
      'non-F-row desktop (layout60/65), standard, and number keyboards share identical height while F-row layouts can be taller',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final deskCtrl = TextEditingController();
    final numCtrl = TextEditingController();
    final stdCtrl = TextEditingController();

    Future<void> pumpWithFormFactor(KeyboardLayoutType factor) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => VKeyboardScope(
            config: VKeyboardConfig(
              desktopFormFactor: factor,
              persistLayoutSelection: false,
              enableClipboardHistory: false,
              syncSystemClipboard: false,
            ),
            child: child!,
          ),
          home: Scaffold(
            body: Column(
              children: [
                VTextField(
                  key: const ValueKey('f_desktop'),
                  controller: deskCtrl,
                  keyboardType: VKeyboardType.desktop,
                ),
                VTextField(
                  key: const ValueKey('f_number'),
                  controller: numCtrl,
                  keyboardType: VKeyboardType.number,
                ),
                VTextField(
                  key: const ValueKey('f_standard'),
                  controller: stdCtrl,
                  keyboardType: VKeyboardType.standard,
                ),
              ],
            ),
          ),
        ),
      );
    }

    await pumpWithFormFactor(KeyboardLayoutType.layout60);

    await tester.tap(find.byKey(const ValueKey('f_desktop')));
    await tester.pumpAndSettle();
    final deskBox =
        tester.renderObject<RenderBox>(find.byType(DesktopFullKeyboard));
    final desk60Height = deskBox.size.height;

    await tester.tap(find.byKey(const ValueKey('f_number')));
    await tester.pumpAndSettle();
    final numBox = tester.renderObject<RenderBox>(find.byType(KeyboardView));
    final numHeight = numBox.size.height;

    await tester.tap(find.byKey(const ValueKey('f_standard')));
    await tester.pumpAndSettle();
    final stdBox = tester.renderObject<RenderBox>(find.byType(KeyboardView));
    final stdHeight = stdBox.size.height;

    expect(numHeight, closeTo(desk60Height, 0.5));
    expect(stdHeight, closeTo(desk60Height, 0.5));

    // F-row expert preset (layout100, 6 rows) keeps its taller height.
    await pumpWithFormFactor(KeyboardLayoutType.layout100);
    await tester.tap(find.byKey(const ValueKey('f_desktop')));
    await tester.pumpAndSettle();
    final desk100Box =
        tester.renderObject<RenderBox>(find.byType(DesktopFullKeyboard));
    expect(desk100Box.size.height, greaterThan(desk60Height));

    deskCtrl.dispose();
    numCtrl.dispose();
    stdCtrl.dispose();
  });
}
