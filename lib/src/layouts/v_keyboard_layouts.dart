import '../models/keyboard_layout.dart';
import '../models/keyboard_type.dart';
import 'builtin_layouts.dart';
import 'locales/layout_de_de.dart';
import 'locales/layout_el_gr.dart';
import 'locales/layout_en_gb.dart';
import 'locales/layout_en_us.dart';
import 'locales/layout_es_es.dart';
import 'locales/layout_fr_fr.dart';
import 'locales/layout_nordic.dart';
import 'locales/layout_ru_ru.dart';
import 'locales/layout_tr_tr.dart';

/// Metadata for a registered keyboard layout.
class VKeyboardLayoutMetadata {
  const VKeyboardLayoutMetadata({
    required this.id,
    required this.displayName,
    required this.shortLabel,
    required this.layout,
    this.builder,
    this.altGrMap = const {},
  });

  /// Layout identifier (e.g. 'en_US', 'de_DE').
  final String id;

  /// Full localized name shown in layout pickers (e.g. 'English (US)', 'Deutsch').
  final String displayName;

  /// Short country/language code shown on keys or badges (e.g. 'EN', 'DE').
  final String shortLabel;

  /// The declarative [KeyboardLayout].
  final KeyboardLayout layout;

  /// Optional factory resolving field-specific variants (e.g. for email/url).
  final KeyboardLayout Function({VKeyboardType type})? builder;

  /// Optional AltGr character remapping table for desktop keyboards.
  final Map<String, String> altGrMap;
}

/// Global registry for virtual keyboard layouts.
///
/// Pre-registers built-in layouts (`en_US`, `en_GB`, `de_DE`, `fr_FR`, `es_ES`,
/// `nordic`, `tr_TR`, `ru_RU`, `el_GR`) and allows developers to register custom
/// layouts for runtime switching.
class VKeyboardLayouts {
  VKeyboardLayouts._();

  static final Map<String, VKeyboardLayoutMetadata> _registry = {};
  static bool _initialized = false;

  static void _ensureInitialized() {
    if (_initialized) return;
    _initialized = true;

    // 1. en_US
    _registerInternal(
      VKeyboardLayoutMetadata(
        id: 'en_US',
        displayName: 'English (US)',
        shortLabel: 'EN',
        layout: BuiltinLayouts.qwerty,
        builder: ({VKeyboardType type = VKeyboardType.standard}) =>
            LayoutEnUs.build(type: type),
      ),
    );

    // 2. en_GB
    _registerInternal(
      VKeyboardLayoutMetadata(
        id: 'en_GB',
        displayName: 'English (UK)',
        shortLabel: 'EN',
        layout: LayoutEnGb.build(),
        builder: ({VKeyboardType type = VKeyboardType.standard}) =>
            LayoutEnGb.build(type: type),
        altGrMap: const {'4': '€'},
      ),
    );

    // 3. de_DE
    _registerInternal(
      VKeyboardLayoutMetadata(
        id: 'de_DE',
        displayName: 'Deutsch',
        shortLabel: 'DE',
        layout: LayoutDeDe.build(),
        builder: ({VKeyboardType type = VKeyboardType.standard}) =>
            LayoutDeDe.build(type: type),
        altGrMap: const {
          'q': '@',
          'e': '€',
          '7': '{',
          '8': '[',
          '9': ']',
          '0': '}',
          'ß': '\\',
          'm': 'µ',
          '+': '~',
        },
      ),
    );

    // 4. fr_FR
    _registerInternal(
      VKeyboardLayoutMetadata(
        id: 'fr_FR',
        displayName: 'Français',
        shortLabel: 'FR',
        layout: LayoutFrFr.build(),
        builder: ({VKeyboardType type = VKeyboardType.standard}) =>
            LayoutFrFr.build(type: type),
        altGrMap: const {
          'e': '€',
          'a': '@',
          '0': '@',
          '2': '~',
          '3': '#',
          '4': '{',
          '5': '[',
          '8': '_',
          '=': '}',
        },
      ),
    );

    // 5. es_ES
    _registerInternal(
      VKeyboardLayoutMetadata(
        id: 'es_ES',
        displayName: 'Español',
        shortLabel: 'ES',
        layout: LayoutEsEs.build(),
        builder: ({VKeyboardType type = VKeyboardType.standard}) =>
            LayoutEsEs.build(type: type),
        altGrMap: const {
          'e': '€',
          '1': '|',
          '2': '@',
          '3': '#',
          '4': '~',
        },
      ),
    );

    // 6. nordic
    _registerInternal(
      VKeyboardLayoutMetadata(
        id: 'nordic',
        displayName: 'Nordic',
        shortLabel: 'NO/SE',
        layout: LayoutNordic.build(),
        builder: ({VKeyboardType type = VKeyboardType.standard}) =>
            LayoutNordic.build(type: type),
        altGrMap: const {
          'e': '€',
          '2': '@',
          '7': '{',
          '8': '[',
          '9': ']',
          '0': '}',
        },
      ),
    );

    // 7. tr_TR
    _registerInternal(
      VKeyboardLayoutMetadata(
        id: 'tr_TR',
        displayName: 'Türkçe',
        shortLabel: 'TR',
        layout: LayoutTrTr.build(),
        builder: ({VKeyboardType type = VKeyboardType.standard}) =>
            LayoutTrTr.build(type: type),
        altGrMap: const {
          't': '₺',
          'e': '€',
          'q': '@',
        },
      ),
    );

    // 8. ru_RU
    _registerInternal(
      VKeyboardLayoutMetadata(
        id: 'ru_RU',
        displayName: 'Русский',
        shortLabel: 'RU',
        layout: LayoutRuRu.build(),
        builder: ({VKeyboardType type = VKeyboardType.standard}) =>
            LayoutRuRu.build(type: type),
        altGrMap: const {
          'e': '€',
          'r': '₽',
        },
      ),
    );

    // 9. el_GR
    _registerInternal(
      VKeyboardLayoutMetadata(
        id: 'el_GR',
        displayName: 'Ελληνικά',
        shortLabel: 'EL',
        layout: LayoutElGr.build(),
        builder: ({VKeyboardType type = VKeyboardType.standard}) =>
            LayoutElGr.build(type: type),
        altGrMap: const {
          'e': '€',
        },
      ),
    );
  }

  static void _registerInternal(VKeyboardLayoutMetadata meta) {
    _registry[meta.id] = meta;
  }

  /// Registers a [KeyboardLayout] with display information so it can appear in
  /// `enabledLayouts` and be selected via the globe key.
  static void register(
    KeyboardLayout layout, {
    required String displayName,
    String? shortLabel,
    KeyboardLayout Function({VKeyboardType type})? builder,
    Map<String, String>? altGr,
  }) {
    _ensureInitialized();
    final meta = VKeyboardLayoutMetadata(
      id: layout.id,
      displayName: displayName,
      shortLabel: shortLabel ??
          (layout.id.length >= 2 ? layout.id.substring(0, 2).toUpperCase() : layout.id),
      layout: layout,
      builder: builder,
      altGrMap: altGr ?? const {},
    );
    _registry[layout.id] = meta;
  }

  /// Gets the [VKeyboardLayoutMetadata] for [id], or null if not registered.
  static VKeyboardLayoutMetadata? getMetadata(String id) {
    _ensureInitialized();
    return _registry[id];
  }

  /// Gets the [KeyboardLayout] for [id].
  ///
  /// Optionally adapts to [type] (standard, email, url, etc.).
  static KeyboardLayout? getLayout(
    String id, {
    VKeyboardType type = VKeyboardType.standard,
  }) {
    _ensureInitialized();
    final meta = _registry[id];
    if (meta == null) return null;
    if (meta.builder != null) {
      return meta.builder!(type: type);
    }
    return meta.layout;
  }

  /// Returns the display name for [id] (e.g. 'Deutsch'), falling back to [id].
  static String getDisplayName(String id) {
    _ensureInitialized();
    return _registry[id]?.displayName ?? id;
  }

  /// Returns the short code for [id] (e.g. 'DE'), falling back to [id].
  static String getShortLabel(String id) {
    _ensureInitialized();
    return _registry[id]?.shortLabel ??
        (id.length >= 2 ? id.substring(0, 2).toUpperCase() : id);
  }

  /// Returns the AltGr character map for [id], or an empty map.
  static Map<String, String> getAltGr(String id) {
    _ensureInitialized();
    return _registry[id]?.altGrMap ?? const {};
  }

  /// All registered layout identifiers.
  static List<String> get registeredIds {
    _ensureInitialized();
    return List.unmodifiable(_registry.keys);
  }

  /// All registered layout metadata items.
  static List<VKeyboardLayoutMetadata> get all {
    _ensureInitialized();
    return List.unmodifiable(_registry.values);
  }
}
