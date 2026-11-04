import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_v_keyboard/flutter_v_keyboard.dart';

const _viewport = Size(1000, 800);

/// Pumps 16 ms frames for ~800 ms after focusing [node] (covers the delayed
/// scroll-into-view plus its animation and any snap-back), and returns the
/// largest deviation seen. Transient jumps settle back, so checking only the
/// final state would miss them.
Future<({double page, double tab})> _focusAndSample(
  WidgetTester tester,
  FocusNode node, {
  required ScrollPosition Function() pagePosition,
  required TabController tabController,
}) async {
  final initialPage = pagePosition().pixels;
  final initialTab = tabController.offset;
  var maxPage = 0.0;
  var maxTab = 0.0;

  node.requestFocus();
  for (var elapsed = 0; elapsed <= 800; elapsed += 16) {
    await tester.pump(const Duration(milliseconds: 16));
    maxPage = math.max(maxPage, (pagePosition().pixels - initialPage).abs());
    maxTab = math.max(maxTab, (tabController.offset - initialTab).abs());
  }
  await tester.pumpAndSettle();
  return (page: maxPage, tab: maxTab);
}

Widget _app(Widget home) => MaterialApp(
      builder: (context, child) =>
          VKeyboardScope(floating: true, child: child!),
      home: Material(child: home),
    );

Widget _field(FocusNode node, Alignment alignment, {Key? key}) => Align(
      alignment: alignment,
      child: SizedBox(
        key: key,
        width: 200,
        child: VTextField(focusNode: node),
      ),
    );

void _setViewport(WidgetTester tester) {
  tester.view.physicalSize = _viewport;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

ScrollPosition _pagePosition(WidgetTester tester) => tester
    .state<ScrollableState>(find
        .descendant(
          of: find.byType(TabBarView),
          matching: find.byType(Scrollable),
        )
        .first)
    .position;

void main() {
  final linux = TargetPlatformVariant.only(TargetPlatform.linux);

  group('scroll focused field into view', () {
    testWidgets(
      'does not move a TabBarView when the field is on the left of tab 1',
      variant: linux,
      (tester) async {
        _setViewport(tester);
        final node = FocusNode();
        addTearDown(node.dispose);
        late TabController tabController;
        await tester.pumpWidget(_app(
          DefaultTabController(
            length: 3,
            initialIndex: 1,
            child: Builder(builder: (context) {
              tabController = DefaultTabController.of(context);
              return TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  const SizedBox(),
                  _field(node, Alignment.centerLeft),
                  const SizedBox(),
                ],
              );
            }),
          ),
        ));

        final deviation = await _focusAndSample(
          tester,
          node,
          pagePosition: () => _pagePosition(tester),
          tabController: tabController,
        );

        expect(deviation.page, 0);
        expect(deviation.tab, 0);
      },
    );

    testWidgets(
      'does not move a TabBarView when the field is on the right of tab 0',
      variant: linux,
      (tester) async {
        _setViewport(tester);
        final node = FocusNode();
        addTearDown(node.dispose);
        late TabController tabController;
        await tester.pumpWidget(_app(
          DefaultTabController(
            length: 3,
            child: Builder(builder: (context) {
              tabController = DefaultTabController.of(context);
              return TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _field(node, Alignment.centerRight),
                  const SizedBox(),
                  const SizedBox(),
                ],
              );
            }),
          ),
        ));

        final deviation = await _focusAndSample(
          tester,
          node,
          pagePosition: () => _pagePosition(tester),
          tabController: tabController,
        );

        expect(_pagePosition(tester).pixels, 0);
        expect(deviation.page, 0);
        expect(deviation.tab, 0);
      },
    );

    testWidgets(
      'scrolls the vertical ancestor but not a TabBarView nested inside it',
      variant: linux,
      (tester) async {
        _setViewport(tester);
        final node = FocusNode();
        addTearDown(node.dispose);
        const fieldKey = Key('field');
        late TabController tabController;
        await tester.pumpWidget(_app(
          DefaultTabController(
            length: 3,
            initialIndex: 1,
            child: Builder(builder: (context) {
              tabController = DefaultTabController.of(context);
              return CustomScrollView(
                slivers: [
                  // Puts the field partly below the bottom edge.
                  const SliverToBoxAdapter(child: SizedBox(height: 700)),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 120,
                      child: TabBarView(
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          const SizedBox(),
                          _field(node, Alignment.centerLeft, key: fieldKey),
                          const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 600)),
                ],
              );
            }),
          ),
        ));

        final deviation = await _focusAndSample(
          tester,
          node,
          pagePosition: () => _pagePosition(tester),
          tabController: tabController,
        );

        expect(deviation.page, 0);
        expect(deviation.tab, 0);
        expect(
          tester.getRect(find.byKey(fieldKey)).center.dy,
          closeTo(_viewport.height / 2, 1),
        );
      },
    );

    testWidgets(
      'still scrolls a field near the bottom of a vertical scroll view',
      variant: linux,
      (tester) async {
        _setViewport(tester);
        final node = FocusNode();
        addTearDown(node.dispose);
        const fieldKey = Key('field');
        await tester.pumpWidget(_app(
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 740),
                _field(node, Alignment.center, key: fieldKey),
                const SizedBox(height: 600),
              ],
            ),
          ),
        ));
        expect(
          tester.getRect(find.byKey(fieldKey)).center.dy,
          greaterThan(_viewport.height - 100),
        );

        node.requestFocus();
        await tester.pump(const Duration(milliseconds: 800));
        await tester.pumpAndSettle();

        expect(
          tester.getRect(find.byKey(fieldKey)).center.dy,
          closeTo(_viewport.height / 2, 1),
        );
      },
    );
  });
}
