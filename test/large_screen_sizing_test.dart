import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_v_keyboard/flutter_v_keyboard.dart';

void main() {
  group('Large Screen & 27-inch Monitor Sizing', () {
    test('Default desktop scaling on 27-inch 1080p and 1440p displays is comfortably tall', () {
      // 1080p 27-inch display
      const mq1080 = MediaQueryData(
        size: Size(1920, 1080),
      );
      final metrics1080 = KeyboardMetrics.resolve(mq1080, rows: 5);
      // On 1080p, baseline height must not be squished to the old 282px cap.
      // It should naturally scale into the 400px - 480px range.
      expect(metrics1080.height, greaterThan(400.0));
      expect(metrics1080.height, lessThanOrEqualTo(1080 * 0.50));

      // Compact numeric pad on 1920-wide screen defaults to 480.0px width
      final compactMetrics1080 = KeyboardMetrics.resolve(mq1080, rows: 4, compact: true);
      expect(compactMetrics1080.maxWidth, 480.0);

      // 1440p 27-inch display
      const mq1440 = MediaQueryData(
        size: Size(2560, 1440),
      );
      final metrics1440 = KeyboardMetrics.resolve(mq1440, rows: 5);
      expect(metrics1440.height, greaterThan(450.0));
    });

    test('Default tablet scaling on 10-inch landscape tablet is compact and does not occupy half the screen', () {
      // 1280x800 typical 10-inch Android tablet or iPad in landscape
      const mqTablet = MediaQueryData(
        size: Size(1280, 800),
      );
      final metrics = KeyboardMetrics.resolve(mqTablet, rows: 5);
      // On tablet in landscape, keyboard height should be around 240px-290px
      // (approx. 30%-36% of screen height) instead of covering 50% (400px).
      expect(metrics.height, lessThan(300.0));
      expect(metrics.height, greaterThan(220.0));
    });

    test('MacBook / laptop displays (e.g. 1470x956 MacBook Air) stay compact (~33% total height) instead of taking half the screen', () {
      for (final size in const [
        Size(1440, 900),
        Size(1470, 923),
        Size(1470, 956),
        Size(1512, 982),
        Size(1710, 1107),
      ]) {
        final mq = MediaQueryData(size: size);
        final metrics = KeyboardMetrics.resolve(mq, rows: 5);
        expect(metrics.height, lessThan(size.height * 0.35),
            reason: '5-row height at $size should stay compact');
        expect(metrics.height, greaterThan(240.0));
      }
    });

    test('Explicit VKeyboardConfig.keyboardHeight overrides dynamic calculations', () {
      const mq = MediaQueryData(size: Size(1920, 1080));
      const config = VKeyboardConfig(keyboardHeight: 460.0);

      final metrics = KeyboardMetrics.resolve(mq, rows: 5, config: config);
      expect(metrics.height, 460.0);

      final baseline = KeyboardMetrics.desktopBaselineHeight(mq, config: config);
      expect(baseline, 460.0);
    });

    test('Explicit VKeyboardConfig.keyboardHeightFactor scales viewport proportionally', () {
      const mq = MediaQueryData(size: Size(1920, 1080));
      const config = VKeyboardConfig(keyboardHeightFactor: 0.42);

      final baseline = KeyboardMetrics.desktopBaselineHeight(mq, config: config);
      expect(baseline, closeTo(1080 * 0.42, 25.0));
    });

    test('Explicit VKeyboardConfig.numericPadMaxWidth and maxKeyboardWidth are applied', () {
      const mq = MediaQueryData(size: Size(1920, 1080));
      const config = VKeyboardConfig(
        numericPadMaxWidth: 540.0,
        maxKeyboardWidth: 1000.0,
      );

      final compactMetrics = KeyboardMetrics.resolve(mq, rows: 4, compact: true, config: config);
      expect(compactMetrics.maxWidth, 540.0);

      final normalMetrics = KeyboardMetrics.resolve(mq, rows: 5, compact: false, config: config);
      expect(normalMetrics.maxWidth, 1000.0);
    });

    testWidgets('VKeyboardScope on 27-inch monitor applies tall desktop height and numeric pad width', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final textCtrl = TextEditingController();
      final numCtrl = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => VKeyboardScope(
            config: const VKeyboardConfig(
              desktopFormFactor: KeyboardLayoutType.layout100,
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
                  key: const ValueKey('text_field'),
                  controller: textCtrl,
                  keyboardType: VKeyboardType.desktop,
                ),
                VTextField(
                  key: const ValueKey('num_field'),
                  controller: numCtrl,
                  keyboardType: VKeyboardType.number,
                ),
              ],
            ),
          ),
        ),
      );

      // Open desktop full keyboard (layout100)
      await tester.tap(find.byKey(const ValueKey('text_field')));
      await tester.pumpAndSettle();

      final fullKb = tester.renderObject<RenderBox>(find.byType(DesktopFullKeyboard));
      expect(fullKb.size.height, greaterThan(450.0));

      // Open number pad
      await tester.tap(find.byKey(const ValueKey('num_field')));
      await tester.pumpAndSettle();

      final kbView = tester.widget<KeyboardView>(find.byType(KeyboardView));
      expect(kbView.metrics.maxWidth, 480.0);
      expect(kbView.metrics.height, greaterThan(400.0));

      textCtrl.dispose();
      numCtrl.dispose();
    });

    testWidgets('VKeyboardScope respects custom keyboardHeight and numericPadMaxWidth', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final numCtrl = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => VKeyboardScope(
            config: const VKeyboardConfig(
              keyboardHeight: 480.0,
              numericPadMaxWidth: 560.0,
              persistLayoutSelection: false,
              enableClipboardHistory: false,
              syncSystemClipboard: false,
            ),
            child: child!,
          ),
          home: Scaffold(
            body: VTextField(
              key: const ValueKey('num_custom'),
              controller: numCtrl,
              keyboardType: VKeyboardType.number,
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('num_custom')));
      await tester.pumpAndSettle();

      final kbView = tester.widget<KeyboardView>(find.byType(KeyboardView));
      expect(kbView.metrics.maxWidth, 560.0);
      expect(kbView.metrics.height, closeTo(480.0, 1.0));

      numCtrl.dispose();
    });

    testWidgets('VKeyboardScope on 1470x956 MacBook Air keeps DesktopFullKeyboard compact (~33% height) while 2560x1440 remains spacious', (tester) async {
      tester.view.physicalSize = const Size(1470, 956);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final deskCtrl = TextEditingController();
      final numCtrl = TextEditingController();

      Future<void> pumpForViewport() async {
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
              body: Column(
                children: [
                  VTextField(
                    key: const ValueKey('mac_desk'),
                    controller: deskCtrl,
                    keyboardType: VKeyboardType.desktop,
                  ),
                  VTextField(
                    key: const ValueKey('mac_num'),
                    controller: numCtrl,
                    keyboardType: VKeyboardType.number,
                  ),
                ],
              ),
            ),
          ),
        );
      }

      await pumpForViewport();
      await tester.tap(find.byKey(const ValueKey('mac_desk')));
      await tester.pumpAndSettle();

      final macKb =
          tester.renderObject<RenderBox>(find.byType(DesktopFullKeyboard));
      // Previously ~442px (46.2% of 956px); now ~316px (~33.1% including 36px bottom bar).
      expect(macKb.size.height, lessThan(340.0));
      expect(macKb.size.height, greaterThan(290.0));

      await tester.tap(find.byKey(const ValueKey('mac_num')));
      await tester.pumpAndSettle();
      final macNum = tester.renderObject<RenderBox>(find.byType(KeyboardView));
      expect(macNum.size.height, closeTo(macKb.size.height, 0.5));

      // Verify 27-inch 2K (2560x1440) remains unchanged and comfortable (~510px total = 35.4%).
      tester.view.physicalSize = const Size(2560, 1440);
      await pumpForViewport();
      await tester.tap(find.byKey(const ValueKey('mac_desk')));
      await tester.pumpAndSettle();

      final qhdKb =
          tester.renderObject<RenderBox>(find.byType(DesktopFullKeyboard));
      expect(qhdKb.size.height, greaterThan(490.0));
      expect(qhdKb.size.height, lessThan(530.0));

      deskCtrl.dispose();
      numCtrl.dispose();
    });
  });
}
