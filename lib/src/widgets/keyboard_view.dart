import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controller/v_keyboard_controller.dart';
import '../models/key_data.dart';
import '../responsive/keyboard_metrics.dart';
import '../theme/v_keyboard_theme.dart';
import 'keyboard_key.dart';

/// Renders the current keyboard page: a background, responsive key grid and a
/// bottom safe-area / dismiss bar. Centred and width-limited on large viewports.
///
/// This widget rebuilds only when structural state changes (page / shift /
/// layout) — typing does not rebuild it (see [VKeyboardController]).
class KeyboardView extends StatelessWidget {
  const KeyboardView({
    super.key,
    required this.controller,
    required this.theme,
    required this.metrics,
    required this.rows,
    required this.bottomSafeArea,
    this.showHideKeyboardButton,
    this.hideIcon,
    this.onHide,
  });

  final VKeyboardController controller;
  final VKeyboardTheme theme;
  final KeyboardMetrics metrics;
  final List<List<KeyData>> rows;
  final double bottomSafeArea;

  /// Whether to display a bottom dismiss bar with a downward chevron
  /// (like Google Keyboard / Gboard). Defaults to
  /// [VKeyboardConfig.showHideKeyboardButton] on non-desktop layouts.
  final bool? showHideKeyboardButton;

  /// Optional icon to use for the dismiss button. Defaults to
  /// [Icons.keyboard_arrow_down_rounded].
  final IconData? hideIcon;

  /// Optional custom callback invoked when the dismiss button is tapped.
  /// Defaults to [VKeyboardController.hide].
  final VoidCallback? onHide;

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
                for (var j = 0; j < rows[i].length; j++)
                  VirtualKey(
                    // Row+column index guarantees uniqueness (a desktop row can
                    // hold several otherwise-identical keys, e.g. two Shifts).
                    key: ValueKey('vk_${i}_$j'),
                    data: rows[i][j],
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

    final shouldShowHide = showHideKeyboardButton ??
        (controller.config.showHideKeyboardButton &&
            metrics.formFactor != DeviceFormFactor.desktop);
    final effectiveBottomBarHeight = shouldShowHide
        ? math.max(bottomSafeArea, 36.0)
        : bottomSafeArea;

    return Material(
      color: theme.backgroundColor,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: metrics.maxWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: theme.contentPadding.add(
                    EdgeInsets.symmetric(horizontal: metrics.horizontalPadding),
                  ),
                  child: grid,
                ),
                if (shouldShowHide)
                  _buildBottomBar(context, effectiveBottomBarHeight)
                else if (effectiveBottomBarHeight > 0)
                  SizedBox(height: effectiveBottomBarHeight),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, double height) {
    final hasOverlay = Overlay.maybeOf(context) != null;
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(
        horizontal: metrics.horizontalPadding + 4,
      ),
      alignment: Alignment.centerLeft,
      child: Semantics(
        button: true,
        label: 'Close keyboard',
        child: Tooltip(
          message: hasOverlay ? 'Close keyboard' : '',
          child: Material(
            color: Colors.transparent,
            child: InkResponse(
              onTap: onHide ?? controller.hide,
              radius: 20,
              highlightColor: theme.keyColor.withValues(alpha: 0.5),
              splashColor: theme.accentColor.withValues(alpha: 0.2),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Icon(
                  hideIcon ?? Icons.keyboard_arrow_down_rounded,
                  size: 24,
                  color: theme.iconColor.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
