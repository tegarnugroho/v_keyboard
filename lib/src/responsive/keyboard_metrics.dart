import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../config/v_keyboard_config.dart';

/// Device form factor derived from the viewport.
enum DeviceFormFactor { phone, tablet, desktop }

/// Responsive sizing for the keyboard, computed from the viewport — never
/// hard-coded. Adapts to screen size, orientation, platform and form factor,
/// and centres + width-limits the keyboard on large desktop windows.
@immutable
class KeyboardMetrics {
  const KeyboardMetrics({
    required this.height,
    required this.maxWidth,
    required this.horizontalPadding,
    required this.rowSpacing,
    required this.formFactor,
    required this.isLandscape,
  });

  /// Total keyboard height (excluding the bottom safe-area inset).
  final double height;

  /// Maximum content width; the keyboard is centred when the viewport is wider.
  final double maxWidth;

  /// Outer horizontal padding around the key grid.
  final double horizontalPadding;

  /// Vertical gap between key rows.
  final double rowSpacing;

  final DeviceFormFactor formFactor;
  final bool isLandscape;

  /// Computes metrics from [mq]. [rows] is the number of key rows in the
  /// current layout so key height stays sensible across layouts.
  ///
  /// Developer configuration from [config] (e.g. [VKeyboardConfig.keyboardHeight],
  /// [VKeyboardConfig.keyboardHeightFactor], [VKeyboardConfig.keyHeight],
  /// [VKeyboardConfig.numericPadMaxWidth]) takes priority when specified.
  factory KeyboardMetrics.resolve(
    MediaQueryData mq, {
    required int rows,
    bool compact = false,
    VKeyboardConfig? config,
  }) {
    final size = mq.size;
    final isLandscape = size.width >= size.height;
    final shortestSide = size.shortestSide;
    final formFactor = _formFactor(shortestSide);

    // Height as a fraction of the viewport, tuned per form factor + orientation,
    // then clamped to sane bounds.
    double fraction;
    double minH;
    double maxH;
    switch (formFactor) {
      case DeviceFormFactor.phone:
        fraction = config?.keyboardHeightFactor ?? (isLandscape ? 0.52 : 0.36);
        minH = config?.minKeyboardHeight ?? 180;
        maxH = config?.maxKeyboardHeight ?? (isLandscape ? 320 : 380);
      case DeviceFormFactor.tablet:
        fraction = config?.keyboardHeightFactor ?? (isLandscape ? 0.40 : 0.32);
        minH = config?.minKeyboardHeight ?? 240;
        maxH = config?.maxKeyboardHeight ?? (isLandscape ? 420 : 460);
      case DeviceFormFactor.desktop:
        fraction = config?.keyboardHeightFactor ?? (isLandscape ? 0.38 : 0.34);
        minH = config?.minKeyboardHeight ?? 220;
        // On desktop, allow scaling smoothly up on large monitors (e.g. 1080p, 1440p, 4K)
        maxH = config?.maxKeyboardHeight ??
            math.max(480.0, size.height * (fraction + 0.10));
    }

    // Scale the height by the number of rows relative to a 5-row baseline on
    // phones. On tablet and desktop viewports, all non-F-row layouts (`rows <= 5`:
    // Standard, Number, Email, PIN, etc.) share the canonical 5-row desktop
    // baseline height so switching between field types never shifts UI height.
    final double height;
    final useUnifiedDesktopHeight =
        formFactor != DeviceFormFactor.phone || (kIsWeb && size.width >= 768);
    if (config?.keyboardHeight != null) {
      final min = config?.minKeyboardHeight ?? 180.0;
      final max = config?.maxKeyboardHeight ?? double.infinity;
      height = config!.keyboardHeight!.clamp(min, max);
    } else if (useUnifiedDesktopHeight) {
      final baseline = desktopBaselineHeight(
        mq,
        hasBottomBar: true,
        maxHeightRatio: config?.keyboardHeightFactor ?? 0.44,
        config: config,
      );
      if (rows <= 5) {
        height = baseline;
      } else {
        final extraRowScale = (rows / 5).clamp(1.0, 1.25);
        height = (baseline * extraRowScale)
            .clamp(baseline, math.min(maxH, size.height * 0.55))
            .toDouble();
      }
    } else {
      final rowScale = (rows / 5).clamp(0.55, 1.15);
      height = (size.height * fraction * rowScale).clamp(minH * rowScale, maxH);
    }

    // Compact layouts (numeric/pin/phone) keep a focused, touch-friendly block.
    // On desktop / wide monitors (e.g. 27" POS touch terminals), default to a
    // comfortable 480px width so cashiers can easily hit number keys without strain.
    final defaultCompactWidth = (size.width >= 1200)
        ? 480.0
        : switch (formFactor) {
            DeviceFormFactor.phone => 360.0,
            DeviceFormFactor.tablet => 420.0,
            DeviceFormFactor.desktop => 480.0,
          };
    final compactWidth = config?.numericPadMaxWidth ?? defaultCompactWidth;

    final defaultMaxWidth = switch (formFactor) {
      DeviceFormFactor.phone => double.infinity,
      DeviceFormFactor.tablet => isLandscape ? 760.0 : 640.0,
      DeviceFormFactor.desktop => 840.0,
    };
    final normalMaxWidth = config?.maxKeyboardWidth ?? defaultMaxWidth;

    final maxWidth = compact ? compactWidth : normalMaxWidth;

    final horizontalPadding = formFactor == DeviceFormFactor.phone ? 4.0 : 8.0;
    final rowSpacing = formFactor == DeviceFormFactor.phone ? 6.0 : 8.0;

    return KeyboardMetrics(
      height: height,
      maxWidth: maxWidth,
      horizontalPadding: horizontalPadding,
      rowSpacing: rowSpacing,
      formFactor: formFactor,
      isLandscape: isLandscape,
    );
  }

  /// Canonical content height (excluding bottom utility bar / safe area)
  /// shared by non-F-row [DesktopFullKeyboard] presets (`layout60`, `layout65`)
  /// and standard/numeric [KeyboardView] layouts on tablet and desktop targets.
  static double desktopBaselineHeight(
    MediaQueryData mq, {
    bool hasBottomBar = true,
    double maxHeightRatio = 0.44,
    VKeyboardConfig? config,
  }) {
    if (config?.keyboardHeight != null) {
      return config!.keyboardHeight!;
    }
    final width = mq.size.width;
    final screenH = mq.size.height > 0 ? mq.size.height : 900.0;
    final hPadding = (width * 0.008).clamp(6.0, 16.0);
    final unitWidth = (width - hPadding * 2) / 15;

    // On desktop screens (e.g. 24", 27", 32" monitors at 1080p, 1440p, or 4K),
    // scale the ceiling dynamically with the screen height up to 92.0 so keys
    // have comfortable proportions rather than being squished into thin ribbons.
    final maxRowCeiling = (screenH >= 900)
        ? math.min(92.0, screenH * 0.085)
        : 64.0;
    final rowHeight = config?.keyHeight ??
        (unitWidth * 0.85).clamp(32.0, maxRowCeiling);
    final vPadding = (rowHeight * 0.24).clamp(6.0, 14.0);
    final verticalOuterPadding = vPadding + (hasBottomBar ? 0.0 : vPadding);
    final ratio = config?.keyboardHeightFactor ?? maxHeightRatio;
    final cap = (screenH * ratio).clamp(190.0, screenH * 0.65);
    final computed = 5 * rowHeight + verticalOuterPadding;
    final minH = config?.minKeyboardHeight ?? 190.0;
    final maxH = config?.maxKeyboardHeight ?? cap;
    return computed.clamp(minH, maxH).toDouble();
  }

  static DeviceFormFactor _formFactor(double shortestSide) {
    if (_isDesktopPlatform) return DeviceFormFactor.desktop;
    if (shortestSide >= 600) return DeviceFormFactor.tablet;
    return DeviceFormFactor.phone;
  }

  static bool get _isDesktopPlatform {
    if (kIsWeb) return false;
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
        return true;
      default:
        return false;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is KeyboardMetrics &&
      other.height == height &&
      other.maxWidth == maxWidth &&
      other.horizontalPadding == horizontalPadding &&
      other.rowSpacing == rowSpacing &&
      other.formFactor == formFactor &&
      other.isLandscape == isLandscape;

  @override
  int get hashCode => Object.hash(
      height, maxWidth, horizontalPadding, rowSpacing, formFactor, isLandscape);
}
