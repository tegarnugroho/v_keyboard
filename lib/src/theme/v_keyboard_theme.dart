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
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.elevation = 0,
    this.shadowColor = const Color(0x33000000),
    this.keyPadding = const EdgeInsets.all(3),
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    this.keySpacing = 0,
  })  : functionKeyColor = functionKeyColor ?? specialKeyColor,
        modifierKeyColor = modifierKeyColor ?? specialKeyColor;

  /// Builds a theme that follows Material's color scheme.
  factory VKeyboardTheme.fromTheme(ThemeData theme) {
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return VKeyboardTheme(
      backgroundColor: isDark
          ? const Color(0xFF1C1C20)
          : const Color(0xFFD1D5DB),
      keyColor: isDark ? const Color(0xFF3A3A40) : Colors.white,
      pressedKeyColor: scheme.primary.withValues(alpha: 0.25),
      specialKeyColor: isDark
          ? const Color(0xFF2A2A30)
          : const Color(0xFFADB3BD),
      disabledKeyColor: scheme.onSurface.withValues(alpha: 0.12),
      accentColor: scheme.primary,
      functionKeyColor: isDark
          ? const Color(0xFF26262B)
          : const Color(0xFFBCC1CB),
      modifierKeyColor: isDark
          ? const Color(0xFF2A2A30)
          : const Color(0xFFADB3BD),
      iconColor: scheme.onSurface,
      textStyle: TextStyle(
        fontSize: 22,
        color: scheme.onSurface,
        fontWeight: FontWeight.w400,
      ),
      subLabelStyle: TextStyle(
        fontSize: 10,
        color: scheme.onSurface.withValues(alpha: 0.6),
        fontWeight: FontWeight.w500,
      ),
      elevation: 1,
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

  final Color disabledKeyColor;
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
    Color? disabledKeyColor,
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
      disabledKeyColor: disabledKeyColor ?? this.disabledKeyColor,
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
}
