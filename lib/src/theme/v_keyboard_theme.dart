import 'package:flutter/material.dart';

/// Visual theme for the virtual keyboard.
///
/// Provide one to [VKeyboardScope]; if omitted a theme is derived from
/// the ambient [ThemeData] via [VKeyboardTheme.fromTheme].
@immutable
class VKeyboardTheme {
  // Not const: function/modifier key colours fall back to specialKeyColor.
  // ignore: prefer_const_constructors_in_immutables
  VKeyboardTheme({
    required this.backgroundColor,
    required this.keyColor,
    required this.pressedKeyColor,
    required this.specialKeyColor,
    required this.disabledKeyColor,
    required this.textStyle,
    required this.iconColor,
    required this.subLabelStyle,
    required this.accentColor,
    Color? functionKeyColor,
    Color? modifierKeyColor,
    Color? activeKeyColor,
    Color? activeForegroundColor,
    this.keyBorderColor,
    this.containerBorderColor,
    this.hoverKeyColor,
    this.enterKeyColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.elevation = 0,
    this.shadowColor = const Color(0x33000000),
    this.keyPadding = const EdgeInsets.all(3),
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    this.keySpacing = 0,
  })  : functionKeyColor = functionKeyColor ?? specialKeyColor,
        modifierKeyColor = modifierKeyColor ?? specialKeyColor,
        activeKeyColor = activeKeyColor ?? accentColor,
        activeForegroundColor = activeForegroundColor ??
            ((activeKeyColor ?? accentColor).computeLuminance() > 0.5
                ? const Color(0xFF1F2937)
                : Colors.white);

  /// Built-in light keyboard theme preset.
  factory VKeyboardTheme.light({
    Color accentColor = Colors.indigo,
    String? fontFamily,
  }) {
    return _preset(
      accentColor: accentColor,
      brightness: Brightness.light,
      fontFamily: fontFamily,
    );
  }

  /// Built-in dark keyboard theme preset.
  factory VKeyboardTheme.dark({
    Color accentColor = Colors.indigo,
    String? fontFamily,
  }) {
    return _preset(
      accentColor: accentColor,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
    );
  }

  /// Builds a theme that follows Material's color scheme.
  factory VKeyboardTheme.fromTheme(ThemeData theme) {
    return _preset(
      accentColor: theme.colorScheme.primary,
      brightness: theme.brightness,
      onSurfaceColor: theme.colorScheme.onSurface,
      fontFamily: theme.textTheme.bodyMedium?.fontFamily,
    );
  }

  final Color backgroundColor;
  final Color keyColor;
  final Color pressedKeyColor;

  /// Color for non-character keys (shift, backspace, switch, enter).
  final Color specialKeyColor;

  /// Color for desktop function keys (Esc, F1–F12). Defaults to
  /// [specialKeyColor].
  final Color functionKeyColor;

  /// Color for desktop modifier/lock keys. Defaults to [specialKeyColor].
  final Color modifierKeyColor;

  /// Accent used for active modifiers, engaged locks and focus/hover hints.
  final Color accentColor;

  /// Background color for actively engaged keys (e.g. active Shift, Caps Lock, held modifiers).
  ///
  /// Defaults to [accentColor].
  final Color activeKeyColor;

  /// Text and icon color for actively engaged keys.
  ///
  /// Defaults to [Colors.white] (or dark gray if [activeKeyColor] has high luminance).
  final Color activeForegroundColor;

  /// Whether this theme is dark (based on background color luminance).
  bool get isDark => backgroundColor.computeLuminance() < 0.5;

  final Color disabledKeyColor;
  final Color? keyBorderColor;
  final Color? containerBorderColor;
  final Color? hoverKeyColor;
  final Color? enterKeyColor;
  final TextStyle textStyle;
  final TextStyle subLabelStyle;
  final Color iconColor;
  final BorderRadiusGeometry borderRadius;
  final double elevation;
  final Color shadowColor;
  final EdgeInsets keyPadding;
  final EdgeInsets contentPadding;
  final double keySpacing;

  VKeyboardTheme copyWith({
    Color? backgroundColor,
    Color? keyColor,
    Color? pressedKeyColor,
    Color? specialKeyColor,
    Color? functionKeyColor,
    Color? modifierKeyColor,
    Color? accentColor,
    Color? activeKeyColor,
    Color? activeForegroundColor,
    Color? disabledKeyColor,
    Color? keyBorderColor,
    Color? containerBorderColor,
    Color? hoverKeyColor,
    Color? enterKeyColor,
    TextStyle? textStyle,
    TextStyle? subLabelStyle,
    Color? iconColor,
    BorderRadiusGeometry? borderRadius,
    double? elevation,
    Color? shadowColor,
    EdgeInsets? keyPadding,
    EdgeInsets? contentPadding,
    double? keySpacing,
  }) {
    return VKeyboardTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      keyColor: keyColor ?? this.keyColor,
      pressedKeyColor: pressedKeyColor ?? this.pressedKeyColor,
      specialKeyColor: specialKeyColor ?? this.specialKeyColor,
      functionKeyColor: functionKeyColor ?? this.functionKeyColor,
      modifierKeyColor: modifierKeyColor ?? this.modifierKeyColor,
      accentColor: accentColor ?? this.accentColor,
      activeKeyColor: activeKeyColor ?? this.activeKeyColor,
      activeForegroundColor:
          activeForegroundColor ?? this.activeForegroundColor,
      disabledKeyColor: disabledKeyColor ?? this.disabledKeyColor,
      keyBorderColor: keyBorderColor ?? this.keyBorderColor,
      containerBorderColor: containerBorderColor ?? this.containerBorderColor,
      hoverKeyColor: hoverKeyColor ?? this.hoverKeyColor,
      enterKeyColor: enterKeyColor ?? this.enterKeyColor,
      textStyle: textStyle ?? this.textStyle,
      subLabelStyle: subLabelStyle ?? this.subLabelStyle,
      iconColor: iconColor ?? this.iconColor,
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      shadowColor: shadowColor ?? this.shadowColor,
      keyPadding: keyPadding ?? this.keyPadding,
      contentPadding: contentPadding ?? this.contentPadding,
      keySpacing: keySpacing ?? this.keySpacing,
    );
  }

  static VKeyboardTheme _preset({
    required Color accentColor,
    required Brightness brightness,
    Color? onSurfaceColor,
    String? fontFamily,
  }) {
    final isDark = brightness == Brightness.dark;
    final surfaceColor =
        onSurfaceColor ?? (isDark ? Colors.white : const Color(0xFF1F2937));

    const defaultFontFamilyFallback = [
      '-apple-system',
      'BlinkMacSystemFont',
      'SF Pro Text',
      'SF Pro',
      'Segoe UI',
      'Roboto',
      'Helvetica Neue',
      'Arial',
      'sans-serif',
    ];

    return VKeyboardTheme(
      backgroundColor:
          isDark ? const Color(0xFF13151B) : const Color(0xFFD1D5DB),
      keyColor: isDark ? const Color(0xFF21242D) : Colors.white,
      pressedKeyColor: isDark
          ? const Color(0xFF353C4E)
          : accentColor.withValues(alpha: 0.25),
      specialKeyColor:
          isDark ? const Color(0xFF1A1D26) : const Color(0xFFADB3BD),
      disabledKeyColor: surfaceColor.withValues(alpha: 0.12),
      accentColor: accentColor,
      activeKeyColor: accentColor,
      activeForegroundColor: accentColor.computeLuminance() > 0.5
          ? const Color(0xFF1F2937)
          : Colors.white,
      functionKeyColor:
          isDark ? const Color(0xFF1A1D26) : const Color(0xFFBCC1CB),
      modifierKeyColor:
          isDark ? const Color(0xFF1A1D26) : const Color(0xFFADB3BD),
      keyBorderColor: isDark ? const Color(0xFF2B3140) : null,
      containerBorderColor: isDark ? const Color(0xFF1E2330) : null,
      hoverKeyColor: isDark ? const Color(0xFF2B303E) : null,
      enterKeyColor: isDark
          ? Color.alphaBlend(
              accentColor.withValues(alpha: 0.35),
              const Color(0xFF13151B),
            )
          : null,
      borderRadius: isDark
          ? const BorderRadius.all(Radius.circular(6))
          : const BorderRadius.all(Radius.circular(8)),
      iconColor: surfaceColor,
      textStyle: TextStyle(
        fontSize: 22,
        color: surfaceColor,
        fontWeight: FontWeight.w400,
        fontFamily: fontFamily,
        fontFamilyFallback: defaultFontFamilyFallback,
      ),
      subLabelStyle: TextStyle(
        fontSize: 10,
        color: isDark
            ? const Color(0xFF94A3B8)
            : surfaceColor.withValues(alpha: 0.6),
        fontWeight: FontWeight.w500,
        fontFamily: fontFamily,
        fontFamilyFallback: defaultFontFamilyFallback,
      ),
      elevation: isDark ? 0 : 1,
      shadowColor: isDark ? const Color(0x40000000) : const Color(0x33000000),
    );
  }
}
