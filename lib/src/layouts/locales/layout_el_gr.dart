import '../../models/key_data.dart';
import '../../models/keyboard_layout.dart';
import '../../models/keyboard_type.dart';
import '../builtin_layouts.dart';
import 'locale_layout_helper.dart';

/// Greek (el_GR) layout with Greek alphabet and € currency.
class LayoutElGr {
  const LayoutElGr._();

  static KeyboardLayout build({
    VKeyboardType type = VKeyboardType.standard,
  }) {
    return KeyboardLayout(
      id: 'el_GR',
      initialPage: 'abc',
      pages: {
        'abc': [
          [
            KeyData.char(';', shift: ':'),
            KeyData.char('ς', shift: 'Σ', alternates: const ['σ']),
            KeyData.char('ε', shift: 'Ε', alternates: const ['έ']),
            KeyData.char('ρ', shift: 'Ρ'),
            KeyData.char('τ', shift: 'Τ'),
            KeyData.char('υ', shift: 'Υ', alternates: const ['ύ', 'ϋ', 'ΰ']),
            KeyData.char('θ', shift: 'Θ'),
            KeyData.char('ι', shift: 'Ι', alternates: const ['ί', 'ϊ', 'ΐ']),
            KeyData.char('ο', shift: 'Ο', alternates: const ['ό']),
            KeyData.char('π', shift: 'Π'),
          ],
          [
            KeyData.char('α', shift: 'Α', alternates: const ['ά']),
            KeyData.char('σ', shift: 'Σ', alternates: const ['ς']),
            KeyData.char('δ', shift: 'Δ'),
            KeyData.char('φ', shift: 'Φ'),
            KeyData.char('γ', shift: 'Γ'),
            KeyData.char('η', shift: 'Η', alternates: const ['ή']),
            KeyData.char('ξ', shift: 'Ξ'),
            KeyData.char('κ', shift: 'Κ'),
            KeyData.char('λ', shift: 'Λ'),
          ],
          [
            KeyData.shift(flex: 1.5),
            KeyData.char('ζ', shift: 'Ζ'),
            KeyData.char('χ', shift: 'Χ'),
            KeyData.char('ψ', shift: 'Ψ'),
            KeyData.char('ω', shift: 'Ω', alternates: const ['ώ']),
            KeyData.char('β', shift: 'Β'),
            KeyData.char('ν', shift: 'Ν'),
            KeyData.char('μ', shift: 'Μ'),
            KeyData.backspace(flex: 1.5),
          ],
          LocaleLayoutHelper.buildBottomRow(type: type),
        ],
        '123': LocaleLayoutHelper.buildNumericSymbolPage(
          'symbols',
          currency: '€',
          includeEmoji: type == VKeyboardType.standard || type == VKeyboardType.multiline,
        ),
        'symbols': LocaleLayoutHelper.buildSymbolPage(
          '123',
          primaryCurrency: '\$',
          includeEmoji: type == VKeyboardType.standard || type == VKeyboardType.multiline,
        ),
        'emoji': BuiltinLayouts.emojiPage,
      },
    );
  }
}
