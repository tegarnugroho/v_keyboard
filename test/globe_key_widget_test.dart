import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_v_keyboard/flutter_v_keyboard.dart';
import 'package:flutter_v_keyboard/src/widgets/keyboard_key.dart';

void main() {
  group('Globe Key Visibility Rules', () {
    testWidgets('globe key is omitted when only 1 layout is enabled (default)',
        (tester) async {
      final textController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VKeyboardScope(
              child: VTextField(controller: textController),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(VTextField));
      await tester.pumpAndSettle();

      expect(find.byType(KeyboardView), findsOneWidget);
      // Globe key should NOT be present
      expect(find.byIcon(Icons.language), findsNothing);
      expect(find.bySemanticsLabel('Switch keyboard language'), findsNothing);
    });

    testWidgets('globe key is omitted by default even when 2+ layouts are enabled',
        (tester) async {
      final textController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VKeyboardScope(
              config: const VKeyboardConfig(
                enabledLayouts: ['en_US', 'de_DE', 'fr_FR'],
              ),
              child: VTextField(controller: textController),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(VTextField));
      await tester.pumpAndSettle();

      expect(find.byType(KeyboardView), findsOneWidget);
      expect(find.byIcon(Icons.language), findsNothing);
    });

    testWidgets('globe key is shown when explicitly enabled via showGlobeKey: true',
        (tester) async {
      final textController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VKeyboardScope(
              config: const VKeyboardConfig(
                enabledLayouts: ['en_US', 'de_DE', 'fr_FR'],
                showGlobeKey: true,
              ),
              child: VTextField(controller: textController),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(VTextField));
      await tester.pumpAndSettle();

      expect(find.byType(KeyboardView), findsOneWidget);
      expect(find.byIcon(Icons.language), findsOneWidget);
      expect(find.bySemanticsLabel('Switch keyboard language'), findsOneWidget);
    });

    testWidgets('globe key is omitted when showGlobeKey is false',
        (tester) async {
      final textController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VKeyboardScope(
              config: const VKeyboardConfig(
                enabledLayouts: ['en_US', 'de_DE'],
                showGlobeKey: false,
              ),
              child: VTextField(controller: textController),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(VTextField));
      await tester.pumpAndSettle();

      expect(find.byType(KeyboardView), findsOneWidget);
      expect(find.byIcon(Icons.language), findsNothing);
    });

    testWidgets('globe key is hidden on number, decimal, pin, and phone pads',
        (tester) async {
      final types = [
        VKeyboardType.number,
        VKeyboardType.decimal,
        VKeyboardType.pin,
        VKeyboardType.phone,
      ];

      for (final type in types) {
        final textController = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: VKeyboardScope(
              config: const VKeyboardConfig(
                enabledLayouts: ['en_US', 'de_DE'],
              ),
              child: Scaffold(
                body: VTextField(
                  controller: textController,
                  keyboardType: type,
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(VTextField));
        await tester.pumpAndSettle();

        expect(
          find.byIcon(Icons.language),
          findsNothing,
          reason: 'Globe key should be hidden for type: $type',
        );
      }
    });

    testWidgets('globe key is hidden for VKeyboardType.custom by default',
        (tester) async {
      final textController = TextEditingController();
      final customLayout = KeyboardLayout(
        id: 'simple',
        initialPage: 'main',
        pages: {
          'main': [
            [KeyData.char('a'), KeyData.char('b')],
          ],
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VKeyboardScope(
              config: const VKeyboardConfig(
                enabledLayouts: ['en_US', 'de_DE'],
              ),
              child: VTextField(
                controller: textController,
                keyboardType: VKeyboardType.custom,
                customLayout: customLayout,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(VTextField));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.language), findsNothing);
    });
  });

  group('Globe Key Tap & Cycling', () {
    testWidgets('tapping globe key cycles to the next enabled layout and shows space bar banner',
        (tester) async {
      final controller = VKeyboardController(
        config: const VKeyboardConfig(
          enabledLayouts: ['en_US', 'de_DE', 'fr_FR'],
          showGlobeKey: true,
          openPickerOnTap: false,
          persistLayoutSelection: false,
        ),
      );
      final textController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VKeyboardScope(
              controller: controller,
              child: VTextField(controller: textController),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(VTextField));
      await tester.pumpAndSettle();

      expect(controller.currentLayoutId, 'en_US');

      // Tap globe key -> switches to de_DE
      final globeFinder = find.byIcon(Icons.language);
      await tester.tap(globeFinder);
      await tester.pump();

      expect(controller.currentLayoutId, 'de_DE');
      // Space bar briefly shows "Deutsch"
      expect(find.text('Deutsch'), findsWidgets);

      // Tap globe key -> switches to fr_FR
      await tester.tap(globeFinder);
      await tester.pump();

      expect(controller.currentLayoutId, 'fr_FR');
      expect(find.text('Français'), findsWidgets);

      // Tap globe key -> wraps around to en_US
      await tester.tap(globeFinder);
      await tester.pump();

      expect(controller.currentLayoutId, 'en_US');
      expect(find.text('English (US)'), findsWidgets);

      // After 1.5s the banner clears
      await tester.pump(const Duration(milliseconds: 1600));
      expect(controller.spaceBarBanner, isNull);
    });

    testWidgets('VKeyboardScope onLayoutChanged callback is invoked on layout switch',
        (tester) async {
      String? changedLayout;
      final textController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VKeyboardScope(
              config: const VKeyboardConfig(
                enabledLayouts: ['en_US', 'de_DE'],
                showGlobeKey: true,
                openPickerOnTap: false,
                persistLayoutSelection: false,
              ),
              onLayoutChanged: (id) => changedLayout = id,
              child: VTextField(controller: textController),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(VTextField));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.language));
      await tester.pumpAndSettle();

      expect(changedLayout, 'de_DE');
    });
  });

  group('Globe Key Long-Press & Layout Picker', () {
    testWidgets('long-pressing globe key opens layout picker and selecting switches layout',
        (tester) async {
      final controller = VKeyboardController(
        config: const VKeyboardConfig(
          enabledLayouts: ['en_US', 'de_DE', 'tr_TR'],
          showGlobeKey: true,
          persistLayoutSelection: false,
        ),
      );
      final textController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: VKeyboardScope(
            controller: controller,
            child: Scaffold(
              body: VTextField(controller: textController),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(VTextField));
      await tester.pumpAndSettle();

      // Long press globe icon to open layout picker
      await tester.longPress(find.byIcon(Icons.language));
      await tester.pumpAndSettle();

      // Picker should display options
      expect(find.textContaining('Türkçe'), findsOneWidget);
      expect(find.textContaining('Deutsch'), findsOneWidget);

      // Tap Türkçe
      await tester.tap(find.textContaining('Türkçe'));
      await tester.pumpAndSettle();

      expect(controller.currentLayoutId, 'tr_TR');
      await tester.pump(const Duration(seconds: 2));
    });
  });

  group('Space Bar Hold Layout Picker', () {
    testWidgets('holding (long-pressing) space bar opens layout picker and switches layout',
        (tester) async {
      final controller = VKeyboardController(
        config: const VKeyboardConfig(
          enabledLayouts: ['en_US', 'de_DE', 'tr_TR'],
          persistLayoutSelection: false,
        ),
      );
      final textController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: VKeyboardScope(
            controller: controller,
            child: Scaffold(
              body: VTextField(controller: textController),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(VTextField));
      await tester.pumpAndSettle();

      // Find the space bar key
      final spaceFinder = find.byWidgetPredicate(
          (w) => w is VirtualKey && w.data.kind == KeyKind.space);
      expect(spaceFinder, findsOneWidget);

      // Long press the space bar
      await tester.longPress(spaceFinder);
      await tester.pumpAndSettle();

      // Picker dialog should be visible with Deutsch and Türkçe
      expect(find.textContaining('Türkçe'), findsOneWidget);
      expect(find.textContaining('Deutsch'), findsOneWidget);

      // Tap Deutsch
      await tester.tap(find.textContaining('Deutsch'));
      await tester.pumpAndSettle();

      expect(controller.currentLayoutId, 'de_DE');
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets(
        'mouse hold on space bar opens picker when scope is in MaterialApp.builder (no Navigator above)',
        (tester) async {
      final controller = VKeyboardController(
        config: const VKeyboardConfig(
          enabledLayouts: ['de_DE', 'en_US'],
          persistLayoutSelection: false,
        ),
      );
      final textController = TextEditingController();
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) =>
              VKeyboardScope(controller: controller, child: child!),
          home: Scaffold(
            body: VTextField(
              controller: textController,
              focusNode: focusNode,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(VTextField));
      await tester.pumpAndSettle();

      final spaceFinder = find.byWidgetPredicate(
          (w) => w is VirtualKey && w.data.kind == KeyKind.space);
      final gesture = await tester.startGesture(
        tester.getCenter(spaceFinder),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(controller.isLayoutPickerOpen, isTrue);
      expect(find.text('Select keyboard layout'), findsOneWidget);
      // The field keeps focus, so the keyboard stays up behind the picker.
      expect(focusNode.hasFocus, isTrue);

      await tester.tap(find.textContaining('English'));
      await tester.pumpAndSettle();

      expect(controller.currentLayoutId, 'en_US');
      expect(controller.isLayoutPickerOpen, isFalse);
      expect(find.text('Select keyboard layout'), findsNothing);
      expect(focusNode.hasFocus, isTrue);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('tapping the picker backdrop closes it without switching',
        (tester) async {
      final controller = VKeyboardController(
        config: const VKeyboardConfig(
          enabledLayouts: ['de_DE', 'en_US'],
          persistLayoutSelection: false,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) =>
              VKeyboardScope(controller: controller, child: child!),
          home: Scaffold(body: VTextField(controller: TextEditingController())),
        ),
      );

      await tester.tap(find.byType(VTextField));
      await tester.pumpAndSettle();

      final result = controller.openLayoutPicker();
      await tester.pumpAndSettle();
      expect(find.text('Select keyboard layout'), findsOneWidget);

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(await result, isNull);
      expect(controller.isLayoutPickerOpen, isFalse);
      expect(controller.currentLayoutId, 'de_DE');
    });

    testWidgets('tapping space bar normally inserts space character and does not open picker',
        (tester) async {
      final controller = VKeyboardController(
        config: const VKeyboardConfig(
          enabledLayouts: ['en_US', 'de_DE'],
          persistLayoutSelection: false,
        ),
      );
      final textController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: VKeyboardScope(
            controller: controller,
            child: Scaffold(
              body: VTextField(controller: textController),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(VTextField));
      await tester.pumpAndSettle();

      final spaceFinder = find.byWidgetPredicate(
          (w) => w is VirtualKey && w.data.kind == KeyKind.space);
      await tester.tap(spaceFinder);
      await tester.pumpAndSettle();

      expect(textController.text, ' ');
      expect(find.textContaining('Deutsch'), findsNothing);
    });
  });

  group('Long-Press Accents', () {
    testWidgets('long-pressing letter with alternates shows accent callout and inserts chosen char',
        (tester) async {
      final controller = VKeyboardController(
        config: const VKeyboardConfig(
          enabledLayouts: ['fr_FR'],
          persistLayoutSelection: false,
          autoShiftFirstLetter: false,
        ),
      );
      final textController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: VKeyboardScope(
            controller: controller,
            child: Scaffold(
              body: VTextField(
                controller: textController,
                config: const VKeyboardConfig(
                  enabledLayouts: ['fr_FR'],
                  persistLayoutSelection: false,
                  autoShiftFirstLetter: false,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(VTextField));
      await tester.pumpAndSettle();

      // Find the 'e' key which has alternates: ['é', 'è', 'ê', 'ë']
      final eKeyFinder = find.byWidgetPredicate((w) =>
          w is VirtualKey &&
          w.data.kind == KeyKind.character &&
          w.data.text == 'e');
      expect(eKeyFinder, findsOneWidget);

      // Long press 'e' key
      await tester.longPress(eKeyFinder);
      await tester.pumpAndSettle();

      // Accent overlay displays 'ê'
      final altFinder = find.text('ê');
      expect(altFinder, findsOneWidget);

      // Tap 'ê'
      await tester.tap(altFinder);
      await tester.pumpAndSettle();

      expect(textController.text, 'ê');
      await tester.pump(const Duration(seconds: 2));
    });
  });

  group('Desktop Layout AltGr Mapping', () {
    testWidgets('AltGr character mapping works in desktop layout',
        (tester) async {
      final controller = VKeyboardController(
        config: const VKeyboardConfig(
          enabledLayouts: ['de_DE'],
          persistLayoutSelection: false,
        ),
      );
      final textController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VKeyboardScope(
              controller: controller,
              child: VTextField(
                controller: textController,
                keyboardType: VKeyboardType.desktop,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(VTextField));
      await tester.pumpAndSettle();

      // Engage AltGr
      controller.modifiers.toggleModifier(ModifierKey.altGr);
      expect(controller.modifiers.altGr, isTrue);

      // Press 'q' (mapped to '@' in de_DE)
      controller.handleKey(KeyData.char('q'));
      expect(textController.text, '@');

      // Re-engage AltGr and press 'e' (mapped to '€' in de_DE)
      controller.modifiers.toggleModifier(ModifierKey.altGr);
      controller.handleKey(KeyData.char('e'));
      expect(textController.text, '@€');
    });
  });
}
