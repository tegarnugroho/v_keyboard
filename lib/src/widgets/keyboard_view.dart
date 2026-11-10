import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controller/v_keyboard_controller.dart';
import '../models/key_data.dart';
import '../models/keyboard_type.dart';
import '../responsive/keyboard_metrics.dart';
import '../theme/v_keyboard_theme.dart';
import 'candidate_bar.dart';
import 'keyboard_key.dart';
import 'layout_picker_dialog.dart';

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
    this.showGlobeKey,
    this.globeIcon,
    this.onGlobeTap,
    this.onGlobeLongPress,
    this.showClipboardButton,
    this.clipboardIcon,
    this.onClipboardTap,
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

  /// Whether to display the globe (layout switcher) button in the bottom bar.
  /// When null, defaults to showing when 2+ layouts are enabled on text-like fields.
  final bool? showGlobeKey;

  /// Optional icon to use for the globe button. Defaults to [Icons.language].
  final IconData? globeIcon;

  /// Optional callback invoked when the globe switcher is tapped.
  final VoidCallback? onGlobeTap;

  /// Optional callback invoked when the globe switcher is long-pressed.
  final VoidCallback? onGlobeLongPress;

  /// Whether to display the clipboard history button on the far right of the bottom bar.
  /// When null, defaults to showing when [VKeyboardConfig.enableClipboardHistory] and
  /// [VKeyboardConfig.showClipboardButton] are true on non-desktop layouts.
  final bool? showClipboardButton;

  /// Optional icon to use for the clipboard button. Defaults to [Icons.content_paste_rounded].
  final IconData? clipboardIcon;

  /// Optional custom callback invoked when the clipboard button is tapped.
  /// Defaults to [VKeyboardController.openClipboardHistory].
  final VoidCallback? onClipboardTap;

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

    final type = controller.session?.type;
    final isTextLike = type == null ||
        type == VKeyboardType.standard ||
        type == VKeyboardType.text ||
        type == VKeyboardType.email ||
        type == VKeyboardType.url ||
        type == VKeyboardType.password ||
        type == VKeyboardType.multiline;
    final isNumeric = type == VKeyboardType.number ||
        type == VKeyboardType.decimal ||
        type == VKeyboardType.phone ||
        type == VKeyboardType.pin;
    final isCustomExplicit = type == VKeyboardType.custom &&
        (controller.session?.config.showGlobeKey == true &&
            controller.config.showGlobeKey);
    final isEligibleType = (isTextLike && !isNumeric) || isCustomExplicit;

    final shouldShowGlobe = showGlobeKey ??
        (controller.config.showGlobeKey &&
            controller.config.enabledLayouts.length >= 2 &&
            metrics.formFactor != DeviceFormFactor.desktop &&
            isEligibleType);

    final shouldShowClipboard = showClipboardButton ??
        (controller.config.enableClipboardHistory &&
            controller.config.showClipboardButton &&
            metrics.formFactor != DeviceFormFactor.desktop);

    final hasBottomBar =
        shouldShowHide || shouldShowGlobe || shouldShowClipboard;
    final effectiveBottomBarHeight = hasBottomBar
        ? math.max(bottomSafeArea, 36.0)
        : bottomSafeArea;

    return Material(
      color: theme.backgroundColor,
      child: Container(
        foregroundDecoration: theme.containerBorderColor != null
            ? BoxDecoration(
                border: Border(
                  top: BorderSide(color: theme.containerBorderColor!, width: 1),
                ),
              )
            : null,
        child: SafeArea(
        top: false,
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: metrics.maxWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.config.enableImeCandidates)
                  CandidateBar(
                    controller: controller,
                    theme: theme,
                    height: controller.config.candidateBarHeight,
                  ),
                Padding(
                  padding: theme.contentPadding.add(
                    EdgeInsets.symmetric(horizontal: metrics.horizontalPadding),
                  ),
                  child: grid,
                ),
                if (hasBottomBar)
                  _buildBottomBar(
                    context,
                    effectiveBottomBarHeight,
                    showHide: shouldShowHide,
                    showGlobe: shouldShowGlobe,
                    showClipboard: shouldShowClipboard,
                  )
                else if (effectiveBottomBarHeight > 0)
                  SizedBox(height: effectiveBottomBarHeight),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    double height, {
    required bool showHide,
    required bool showGlobe,
    required bool showClipboard,
  }) {
    final hasOverlay = Overlay.maybeOf(context) != null;
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(
        horizontal: metrics.horizontalPadding + 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showHide)
                Semantics(
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
              if (showHide && showGlobe) const SizedBox(width: 4),
              if (showGlobe)
                Semantics(
                  button: true,
                  label: 'Switch keyboard language',
                  child: Tooltip(
                    message: hasOverlay ? 'Switch keyboard language' : '',
                    child: Material(
                      color: Colors.transparent,
                      child: InkResponse(
                        onTap: onGlobeTap ??
                            () {
                              if (controller.config.openPickerOnTap) {
                                showVKeyboardLayoutPicker(
                                  context,
                                  controller: controller,
                                  theme: theme,
                                );
                              } else {
                                controller.nextLayout();
                              }
                            },
                        onLongPress: onGlobeLongPress ??
                            () {
                              showVKeyboardLayoutPicker(
                                context,
                                controller: controller,
                                theme: theme,
                              );
                            },
                        radius: 20,
                        highlightColor: theme.keyColor.withValues(alpha: 0.5),
                        splashColor: theme.accentColor.withValues(alpha: 0.2),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Icon(
                            globeIcon ?? Icons.language,
                            size: 24,
                            color: theme.iconColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (showClipboard)
            Semantics(
              button: true,
              label: 'Clipboard History',
              child: Tooltip(
                message: hasOverlay ? 'Clipboard History' : '',
                child: Material(
                  color: Colors.transparent,
                  child: InkResponse(
                    key: const ValueKey('vkeyboard_bottom_bar_clipboard'),
                    onTap: onClipboardTap ?? controller.openClipboardHistory,
                    radius: 20,
                    highlightColor: theme.keyColor.withValues(alpha: 0.5),
                    splashColor: theme.accentColor.withValues(alpha: 0.2),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Icon(
                        clipboardIcon ?? Icons.content_paste_rounded,
                        size: 22,
                        color: theme.iconColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
