import 'package:flutter/material.dart';

import '../controller/virtual_keyboard_controller.dart';
import '../models/key_data.dart';
import '../responsive/keyboard_metrics.dart';
import '../theme/virtual_keyboard_theme.dart';
import 'keyboard_key.dart';

/// Renders the current keyboard page: a background, responsive key grid and a
/// bottom safe-area inset. Centred and width-limited on large viewports.
///
/// This widget rebuilds only when structural state changes (page / shift /
/// layout) — typing does not rebuild it (see [VirtualKeyboardController]).
class KeyboardView extends StatelessWidget {
  const KeyboardView({
    super.key,
    required this.controller,
    required this.theme,
    required this.metrics,
    required this.rows,
    required this.bottomSafeArea,
  });

  final VirtualKeyboardController controller;
  final VirtualKeyboardTheme theme;
  final KeyboardMetrics metrics;
  final List<List<KeyData>> rows;
  final double bottomSafeArea;

  @override
  Widget build(BuildContext context) {
    final rowCount = rows.length;
    final contentHeight = metrics.height -
        theme.contentPadding.vertical -
        metrics.rowSpacing * (rowCount - 1);
    final rowHeight = (contentHeight / rowCount).clamp(36.0, 88.0);

    final grid = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) SizedBox(height: metrics.rowSpacing),
          SizedBox(
            height: rowHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final key in rows[i])
                  KeyboardKey(
                    key: ValueKey('vk_${key.kind}_${key.text ?? key.label ?? key.switchTarget}'),
                    data: key,
                    controller: controller,
                    theme: theme,
                    height: rowHeight,
                  ),
              ],
            ),
          ),
        ],
      ],
    );

    return Material(
      color: theme.backgroundColor,
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: metrics.maxWidth),
            child: Padding(
              padding: theme.contentPadding.add(
                EdgeInsets.symmetric(horizontal: metrics.horizontalPadding),
              ),
              child: grid,
            ),
          ),
        ),
      ),
    );
  }
}
