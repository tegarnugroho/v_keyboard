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

  KeyboardMetrics copyWith({
    double? height,
    double? maxWidth,
    double? horizontalPadding,
    double? rowSpacing,
    DeviceFormFactor? formFactor,
    bool? isLandscape,
  }) =>
      KeyboardMetrics(
        height: height ?? this.height,
        maxWidth: maxWidth ?? this.maxWidth,
        horizontalPadding: horizontalPadding ?? this.horizontalPadding,
        rowSpacing: rowSpacing ?? this.rowSpacing,
        formFactor: formFactor ?? this.formFactor,
        isLandscape: isLandscape ?? this.isLandscape,
      );

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
        fraction = config?.keyboardHeightFactor ?? (isLandscape ? 0.35 : 0.30);
        minH = config?.minKeyboardHeight ?? 200;
        maxH = config?.maxKeyboardHeight ?? (isLandscape ? 340 : 380);
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
      final defaultMaxRatio = defaultFullKeyboardHeightRatio(size);
      final baseline = desktopBaselineHeight(
        mq,
        hasBottomBar: true,
        maxHeightRatio: config?.keyboardHeightFactor ?? defaultMaxRatio,
        config: config,
      );
      if (rows <= 5) {
        height = baseline;
      } else {
        final extraRowScale = (rows / 5).clamp(1.0, 1.25);
        final sixRowRatio = config?.keyboardHeightFactor ??
            defaultFullKeyboardHeightRatio(size, hasFunctionRow: true);
        final ratioCap = size.height * sixRowRatio;
        height = (baseline * extraRowScale)
            .clamp(baseline, math.min(maxH, ratioCap))
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

  /// Whether [size] represents a large desktop monitor (e.g. 24"+ Full HD,
  /// 27" 2K/QHD, Ultrawide, or 4K at `>= 1800` wide and `>= 960` tall).
  ///
  /// Smaller desktop/laptop screens such as 13"-16" laptops (e.g. MacBook Air
  /// `1470x956` or `1440x900`) and tablets (`1280x800`) intentionally stay in
  /// compact landscape scaling (~32%-35% of screen height) so forms and
  /// dialogs remain unobstructed.
  static bool isLargeDesktopDisplay(Size size) =>
      size.width >= 1800 && size.height >= 960;

  /// Default viewport height ratio reserved for the keyboard content area.
  static double defaultFullKeyboardHeightRatio(
    Size size, {
    bool hasFunctionRow = false,
  }) {
    if (isLargeDesktopDisplay(size)) {
      return hasFunctionRow ? 0.55 : 0.44;
    }
    final isLandscape = size.width >= size.height;
    if (hasFunctionRow) {
      return isLandscape ? 0.42 : 0.38;
    }
    return isLandscape ? 0.34 : 0.30;
  }

  /// Maximum key-row height ceiling for tablet and desktop layouts.
  static double desktopMaxRowCeiling(Size size) {
    final screenH = size.height > 0 ? size.height : 900.0;
    if (isLargeDesktopDisplay(size)) {
      return math.min(92.0, screenH * 0.080);
    }
    if (size.width >= size.height) {
      return (screenH * 0.056).clamp(46.0, 62.0);
    }
    return 54.0;
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
    final size = mq.size;
    final width = size.width;
    final screenH = size.height > 0 ? size.height : 900.0;
    final isLargeDisplay = isLargeDesktopDisplay(size);

    final hPadding = (width * 0.008).clamp(6.0, 16.0);
    final unitWidth = (width - hPadding * 2) / 15;

    final maxRowCeiling = desktopMaxRowCeiling(size);
    final rowHeight = config?.keyHeight ??
        (unitWidth * 0.85).clamp(32.0, maxRowCeiling);
    final vPadding = (rowHeight * 0.24).clamp(6.0, 14.0);
    final verticalOuterPadding = vPadding + (hasBottomBar ? 0.0 : vPadding);

    final defaultRatio = maxHeightRatio != 0.44
        ? maxHeightRatio
        : defaultFullKeyboardHeightRatio(size);
    final ratio = config?.keyboardHeightFactor ?? defaultRatio;
    final cap = (screenH * ratio)
        .clamp(180.0, screenH * (isLargeDisplay ? 0.65 : 0.44));
    final computed = 5 * rowHeight + verticalOuterPadding;
    final minH = config?.minKeyboardHeight ?? 180.0;
    final maxH = config?.maxKeyboardHeight ?? cap;
    return computed.clamp(minH, maxH).toDouble();
  }

  static DeviceFormFactor _formFactor(double shortestSide) {
    if (isDesktopPlatform) return DeviceFormFactor.desktop;
    if (shortestSide >= 600) return DeviceFormFactor.tablet;
    return DeviceFormFactor.phone;
  }

  /// Whether the host operating system platform is a desktop OS (Windows, macOS, Linux).
  static bool get isDesktopPlatform {
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
