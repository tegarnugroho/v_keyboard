import 'package:flutter/material.dart';

import '../../models/key_data.dart';
import '../../models/keyboard_type.dart';

/// Shared layout construction helpers for locale layouts.
class LocaleLayoutHelper {
  const LocaleLayoutHelper._();

  static List<KeyData> rowOf(String chars) =>
      chars.split('').map((c) => KeyData.char(c)).toList();

  static KeyData charWithAlternates(
    String char,
    List<String> alternates, {
    String? shift,
    double flex = 1,
  }) =>
      KeyData.char(char, shift: shift, flex: flex, alternates: alternates);

  static List<KeyData> symbolsOf(String chars) =>
      chars.split('').map((c) => KeyData.symbol(c)).toList();

  /// Builds a bottom row customized for the given [type].
  static List<KeyData> buildBottomRow({
    VKeyboardType type = VKeyboardType.standard,
    bool includeEmoji = true,
  }) {
    switch (type) {
      case VKeyboardType.email:
        return [
          KeyData.switchTo('123', label: '123', flex: 1.4),
          KeyData.symbol('@', flex: 1.2),
          KeyData.space(flex: 4.6),
          KeyData.symbol('.', flex: 1.0),
          KeyData.enter(flex: 1.8),
        ];
      case VKeyboardType.url:
        return [
          KeyData.switchTo('123', label: '123', flex: 1.4),
          KeyData.symbol('/', flex: 1.0),
          KeyData.symbol('.', flex: 1.0),
          KeyData.space(flex: 3.3),
          KeyData.symbol('.com', label: '.com', flex: 1.6),
          KeyData.enter(flex: 1.7),
        ];
      case VKeyboardType.multiline:
        return [
          KeyData.switchTo('123', label: '123', flex: 1.4),
          KeyData.symbol(',', flex: 1.0),
          KeyData.space(flex: 4.8),
          KeyData.symbol('.', flex: 1.0),
          KeyData.enter(label: '⏎', flex: 1.8),
        ];
      case VKeyboardType.text:
        return [
          KeyData.switchTo('123', label: '123', flex: 1.4),
          KeyData.symbol(',', flex: 1.0),
          KeyData.space(flex: 4.8),
          KeyData.symbol('.', flex: 1.0),
          KeyData.enter(flex: 1.8),
        ];
      default:
        return [
          KeyData.switchTo('123', label: '123', flex: 1.3),
          if (includeEmoji)
            KeyData.switchTo(
              'emoji',
              label: '☺',
              icon: Icons.sentiment_satisfied_alt_rounded,
              flex: 1.0,
            ),
          KeyData.symbol(',', flex: 0.9),
          KeyData.space(flex: 4.2),
          KeyData.symbol('.', flex: 0.9),
          KeyData.enter(flex: 1.7),
        ];
    }
  }

  /// 123 numeric symbol page with configurable primary [currency] symbol.
  static List<List<KeyData>> buildNumericSymbolPage(
    String moreTarget, {
    String currency = '\$',
    bool includeEmoji = true,
  }) {
    // Replace default $ with locale currency
    final row2Symbols = '-/:;()$currency&@"';
    return [
      symbolsOf('1234567890'),
      symbolsOf(row2Symbols),
      [
        KeyData.switchTo(moreTarget, label: '#+=', flex: 1.5),
        ...symbolsOf('.,?!\''),
        KeyData.backspace(flex: 1.5),
      ],
      [
        KeyData.switchTo('abc', label: 'ABC', flex: 1.4),
        if (includeEmoji)
          KeyData.switchTo(
            'emoji',
            label: '☺',
            icon: Icons.sentiment_satisfied_alt_rounded,
            flex: 1.1,
          ),
        KeyData.space(flex: includeEmoji ? 5.1 : 5.6),
        KeyData.symbol('.', flex: 1),
        KeyData.enter(flex: 1.8),
      ],
    ];
  }

  /// #+= symbol page with configurable extra currency symbols.
  static List<List<KeyData>> buildSymbolPage(
    String backTarget, {
    String primaryCurrency = '€',
    bool includeEmoji = true,
  }) {
    // Row 2 has symbols including currencies
    final row2 = '_\\|~<>$primaryCurrency£¥•';
    return [
      symbolsOf('[]{}#%^*+='),
      symbolsOf(row2),
      [
        KeyData.switchTo(backTarget, label: '123', flex: 1.5),
        ...symbolsOf('.,?!\''),
        KeyData.backspace(flex: 1.5),
      ],
      [
        KeyData.switchTo('abc', label: 'ABC', flex: 1.4),
        if (includeEmoji)
          KeyData.switchTo(
            'emoji',
            label: '☺',
            icon: Icons.sentiment_satisfied_alt_rounded,
            flex: 1.1,
          ),
        KeyData.space(flex: includeEmoji ? 5.1 : 5.6),
        KeyData.symbol('.', flex: 1),
        KeyData.enter(flex: 1.8),
      ],
    ];
  }
}
