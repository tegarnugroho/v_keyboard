<p align="center">
  <img src="https://raw.githubusercontent.com/tegarnugroho/v_keyboard/main/assets/showcase/hero.png" alt="flutter_v_keyboard hero showcase" width="100%">
</p>

# flutter_v_keyboard

A customizable virtual keyboard and text-input system for Flutter, built for mobile, desktop, and web.

[![pub package](https://img.shields.io/pub/v/flutter_v_keyboard.svg)](https://pub.dev/packages/flutter_v_keyboard)
[![platforms](https://img.shields.io/badge/platform-android%20|%20ios%20|%20windows%20|%20macos%20|%20linux%20|%20web-blue.svg)](https://pub.dev/packages/flutter_v_keyboard)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/tegarnugroho/v_keyboard/blob/main/LICENSE)

Unlike simple keyboard widgets, `flutter_v_keyboard` pairs a drop-in `VTextField` with an on-screen text input engine. It delivers precise cursor management, multi-character selection replacement, multiline editing, layout switching, and focus traversal without invoking the host operating system's software keyboard.

---

## Showcase

### Everyday Typing

| Standard | Number / PIN | Password | Multiline |
| :---: | :---: | :---: | :---: |
| <img src="https://raw.githubusercontent.com/tegarnugroho/v_keyboard/main/assets/showcase/mobile_standard.png" width="200" alt="Standard mobile layout"> | <img src="https://raw.githubusercontent.com/tegarnugroho/v_keyboard/main/assets/showcase/mobile_number.png" width="200" alt="Number and PIN layout"> | <img src="https://raw.githubusercontent.com/tegarnugroho/v_keyboard/main/assets/showcase/mobile_password.png" width="200" alt="Password layout"> | <img src="https://raw.githubusercontent.com/tegarnugroho/v_keyboard/main/assets/showcase/mobile_multiline.png" width="200" alt="Multiline input layout"> |

### Customization

| Light Theme | Dark Theme | Emoji Panel |
| :---: | :---: | :---: |
| <img src="https://raw.githubusercontent.com/tegarnugroho/v_keyboard/main/assets/showcase/light_theme.png" width="240" alt="Light theme preset"> | <img src="https://raw.githubusercontent.com/tegarnugroho/v_keyboard/main/assets/showcase/dark_theme.png" width="240" alt="Dark theme preset"> | <img src="https://raw.githubusercontent.com/tegarnugroho/v_keyboard/main/assets/showcase/mobile_emoji.png" width="240" alt="Categorized emoji picker"> |

### Desktop

Full physical desktop layout featuring function keys, navigation clusters, and responsive collapsing sections.

<p align="center">
  <img src="https://raw.githubusercontent.com/tegarnugroho/v_keyboard/main/assets/showcase/desktop_keyboard.png" alt="Desktop keyboard layout with function row and navigation cluster" width="100%">
</p>

Responsive scaling across phones, landscape mode, tablets, and wide desktop windows.

<p align="center">
  <img src="https://raw.githubusercontent.com/tegarnugroho/v_keyboard/main/assets/showcase/responsive.png" alt="Responsive layout scaling across phone, tablet, and desktop" width="100%">
</p>

### Clipboard History

Production-ready clipboard history integrated directly into the virtual keyboard. Tap the clipboard key on the keyboard, search snippets, pin frequent items, and paste directly into the active field.

| Integrated Key | History Panel | Search & Filter |
| :---: | :---: | :---: |
| <img src="https://raw.githubusercontent.com/tegarnugroho/v_keyboard/main/assets/showcase/clipboard_trigger.png" width="240" alt="Integrated clipboard history key"> | <img src="https://raw.githubusercontent.com/tegarnugroho/v_keyboard/main/assets/showcase/clipboard_history.png" width="240" alt="Clipboard history panel with pinned snippets"> | <img src="https://raw.githubusercontent.com/tegarnugroho/v_keyboard/main/assets/showcase/clipboard_search.png" width="240" alt="Search and quick filter chips"> |

---

## Features

### Text Input
- Real cursor positioning, drag selection, and multi-character replacement.
- Multiline editing with newline handling and text overflow wrapping.
- Flutter focus system integration with `TextInputAction` (`next`, `done`, `go`, `search`).
- Native keyboard avoidance by pushing application UI via `viewInsets.bottom`.
- Full respect for `inputFormatters`, `maxLength`, and `readOnly` configurations.

### Keyboard Layouts
- **Alphabetic & Multi-Language**: 15 built-in international layouts (`en_US`, `en_GB`, `de_DE`, `fr_FR`, `es_ES`, `nordic`, `tr_TR`, `ru_RU`, `el_GR`, `ko_KR`, `ja_JP`, `zh_CN`, `zh_TW`, `th_TH`, `vi_VN`).
- **CJK IME & Candidate Bar**: Pure offline algorithmic dictionary engines for Simplified Chinese Pinyin (`zh_CN`), Traditional Chinese Zhuyin/Bopomofo (`zh_TW`), and Japanese Kana/Kanji (`ja_JP`), with an on-screen `CandidateBar` for selecting candidates.
- **Hangul Syllable Composition Engine**: Pure algorithmic Korean syllable composition (`ㅎ` + `ㅏ` + `ㄴ` = `한`), compound vowels (`ㅘ`, `ㅙ`, `ㅢ`), compound batchim (`닭`), batchim splitting (`간` + `ㅏ` = `가나`, `닭` + `ㅣ` = `달기`), and step-by-step backspace decomposition.
- **Kana Voicing Mark Engine**: Algorithmic dakuten (`゛`) and handakuten (`゜`) sound composer for Japanese typing (`か` + `゛` = `が`, `は` + `゜` = `ぱ`).
- **Vietnamese Telex Engine**: Algorithmic Telex syllable composer (`aa` $\rightarrow$ `â`, `aw` $\rightarrow$ `ă`, `ee` $\rightarrow$ `ê`, `oo` $\rightarrow$ `ô`, `ow` $\rightarrow$ `ơ`, `uw`/`w` $\rightarrow$ `ư`, `uow` $\rightarrow$ `ươ`, `dd` $\rightarrow$ `đ`), tone marks (`s, f, r, x, j, z`), modern orthographic tone placement, and backspace decomposition.
- **Smart Latin Auto-Fallback**: Automatically switches non-Latin layouts (Korean, Japanese, Thai, Taiwan Zhuyin, Russian, Greek) to standard Latin QWERTY when typing into `Email`, `URL`, and `Password` fields, while keeping IME engines and diacritic composers suppressed in sensitive fields.
- **Runtime Layout Switching**: Hold (long-press) the space bar, with touch or mouse, to open the layout picker. The picker is drawn by `VKeyboardScope` itself, so it works without a `Navigator` (e.g. in `MaterialApp.builder`) and the keyboard stays open. Includes a space bar preview of the active layout and persistent selection.
- **Accented Characters**: Long-press letter callouts with customizable alternates.
- **Specialized**: Number, decimal, phone, PIN, password, email, and URL layouts.
- **Symbols**: Multi-page switching (`123`, `#+=`) with sticky shift, double-tap caps lock, and locale-specific currency keys (`€`, `£`, `₺`, `₽`, `₩`, `¥`, `฿`, `₫`).
- **Emoji**: Built-in categorized emoji picker with zero external dependencies.
- **Custom**: Declarative layout definition and global layout registry (`VKeyboardLayouts`).

### Desktop Experience
- Edge-to-edge proportional Desktop On-Screen Keyboard (`DesktopFullKeyboard`) powered by dynamic `Expanded(flex: N)` sizing from compact windows to ultrawide and 4K monitors.
- **6 Hardware Form-Factor Presets** (`KeyboardLayoutType`): `layout60` (`Fn` layer), `layout65`, `layout75`, `layout87TKL`, `layout98` (1800-compact), and `layout100` (Full-Size).
- **Windows & macOS Conventions** (`DesktopKeyboardPlatform`): Live OS switcher between Windows (`Ctrl`, `Win`, `AltGr`, `Menu`, `PrtSc`, `Num`) and macOS (`fn`, `⌃ control`, `⌥ option`, `⌘ command`, `F13`–`F15`, `clear`) with `Ctrl` and `Cmd+A/C/X/V` shortcuts.
- **Multi-Language Desktop & CJK IME**: Switch across all 15 built-in locales from the header `🌐` pill or Spacebar long-press, with automatic `CandidateBar` support for Pinyin, Zhuyin, and Kana.
- Full modifier & lock handling: Shift, Ctrl, Alt, AltGr, Meta/Cmd, Fn, Caps Lock, Num Lock, and Scroll Lock with status LEDs.
- Navigation & Numpad clusters: Arrow keys (Inverted-T), Home, End, Page Up, Page Down, Insert, Delete, word navigation (`Ctrl + Arrow`), and word deletion (`Ctrl + Backspace`).
- Hardware keyboard fallback on desktop and web targets, plus custom global shortcuts via `VKeyboardShortcuts`.

### Clipboard History
- Automatic recording of copied and cut text snippets within the virtual keyboard pipeline.
- Instant synchronization with the host operating system clipboard upon opening.
- Persistent local storage surviving application restarts.
- Deduplication with position bumping and original timestamp preservation.
- Snippet pinning to protect critical items from eviction.
- Search filtering with quick filter chips (`All`, `Pinned`, `Recent`).
- Privacy protection: Password, PIN, and sensitive fields are never saved.
- Hardware shortcut support (`Win + V`, `Ctrl + Shift + V`).

---

## Installation

Add `flutter_v_keyboard` to your `pubspec.yaml`:

```bash
flutter pub add flutter_v_keyboard
```

Or add it manually under dependencies:

```yaml
dependencies:
  flutter_v_keyboard: ^0.3.2
```

---

## Quick Start

Wrap your application tree once with `VKeyboardScope`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_v_keyboard/flutter_v_keyboard.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => VKeyboardScope(
        child: child!,
      ),
      home: const FormPage(),
    );
  }
}
```

Replace `TextField` with `VTextField`:

```dart
class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Virtual Keyboard Example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: VTextField(
          controller: _controller,
          keyboardType: VKeyboardType.standard,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Your message',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
```

---

## Multi-Language Layouts

`flutter_v_keyboard` includes 15 built-in international layouts and a runtime layout switcher inspired by Gboard and iOS.

### Built-in Locales

| Layout ID | Language | Type | Key Features |
| :--- | :--- | :--- | :--- |
| `en_US` | English (US) | QWERTY | Standard US keyboard, `$` currency symbol (default) |
| `en_GB` | English (UK) | QWERTY | UK symbols with `£` currency symbol |
| `de_DE` | Deutsch | QWERTZ | Swapped `Y`/`Z`, direct `ä`, `ö`, `ü`, `ß` keys, `€` symbol |
| `fr_FR` | Français | AZERTY | Swapped `A`/`Q` and `Z`/`W`, `M` beside `L`, `é`, `è`, `à`, `ç`, `ù`, `€` symbol |
| `es_ES` | Español | QWERTY | Dedicated `ñ` key, `¿`, `¡`, `€` symbol |
| `nordic` | Nordic | QWERTY | Dedicated `å`, `ä`, `ö`, `æ`, `ø` keys, `€`/`kr` symbols |
| `tr_TR` | Türkçe | Turkish Q | Dedicated `ğ`, `ü`, `ş`, `ı`, `ö`, `ç`, `₺`, strict dotted/dotless casing (`i ↔ İ`, `ı ↔ I`) |
| `ru_RU` | Русский | ЙЦУКЕН | Full Cyrillic alphabet, `₽` currency symbol |
| `el_GR` | Ελληνικά | Greek | Full Greek alphabet, `€` currency symbol |
| `ko_KR` | 한국어 | 2-Set Hangul (두벌식) | Algorithmic syllable composition, compound vowels/batchim, `₩` currency symbol |
| `ja_JP` | 日本語 | JIS Kana | Full Kana alphabet, `¥` currency symbol, voicing marks (`゛`, `゜`) |
| `zh_CN` | 简体中文 | Pinyin | Pinyin QWERTY with fullwidth Chinese punctuation (`，`, `。`, `、`), `¥` symbol |
| `zh_TW` | 繁體中文 | Zhuyin (注音) | Complete Bopomofo phonetic alphabet with tone marks and Traditional punctuation |
| `th_TH` | ภาษาไทย | Kedmanee (เกษมณี) | Full Thai alphabet, independent/dependent vowels, tone marks, Thai numerals, `฿` currency |
| `vi_VN` | Tiếng Việt | Telex QWERTY | Standard QWERTY with built-in algorithmic Telex composer, diacritic alternates, `₫` currency |

### Enabling Multi-Language Support

Specify `enabledLocales` using the type-safe `VKeyboardLocale` enum in `VKeyboardConfig` (or use `enabledLayouts` for custom registered layout IDs). When two or more layouts are enabled, holding (long-pressing) the space bar opens the layout picker dialog / bottom sheet:

```dart
VKeyboardScope(
  config: const VKeyboardConfig(
    // Type-safe enum list (use VKeyboardLocale.values to enable all built-in layouts)
    enabledLocales: [
      VKeyboardLocale.enUS,
      VKeyboardLocale.deDE,
      VKeyboardLocale.frFR,
      VKeyboardLocale.esES,
    ],
    defaultLocale: VKeyboardLocale.enUS,
    persistLayoutSelection: true, // Remembers active layout across app restarts
    showGlobeKey: false,          // Optional bottom-bar globe icon (default: false)
  ),
  onLayoutChanged: (layoutId) {
    debugPrint('Layout switched to: $layoutId');
  },
  child: child!,
);
```

### Space Bar & Layout Switcher

- **Hold Space Bar**: Holding (long-pressing) the space bar, with touch or mouse, opens a layout picker over the keyboard to select any enabled layout. It is rendered by `VKeyboardScope` (no route), so it needs no `Navigator`, keeps focus on the active field, and taps on it never dismiss the keyboard. Tap the backdrop to close it without switching.
- **Space Bar Active Preview**: When multiple layouts are enabled, the space bar subtly displays the active language name (e.g. `English (US)`, `Deutsch`, `Русский`), matching modern keyboard UX.
- **Switch Banner**: Briefly flashes the new layout name on the space bar (~1.5s) upon switching.
- **Optional Globe Key**: Can be enabled via `showGlobeKey: true` if a dedicated bottom-bar button is desired.
- **Persistent State**: The user's chosen layout is automatically stored locally and restored on next application launch.

### Programmatic Control

Access layout controls from any widget using `VKeyboardController`:

```dart
final controller = VKeyboardController.of(context);

// Read current active layout
final current = controller.currentLayoutId;
final locale = controller.currentLocale; // VKeyboardLocale?

// Switch layout directly using enum or string ID
controller.setLocale(VKeyboardLocale.deDE);
// or: controller.setLayout('de_DE');

// Cycle to next layout
controller.nextLayout();

// Listen to layout changes
controller.onLayoutChanged.listen((id) {
  debugPrint('New layout: $id');
});

// Open the layout picker manually (rendered by VKeyboardScope).
// Completes with the selected layout id, or null if dismissed.
final picked = await controller.openLayoutPicker();
// controller.isLayoutPickerOpen / controller.closeLayoutPicker()
```

### Custom Layout Registration

Register your own custom language layouts globally with `VKeyboardLayouts`:

```dart
VKeyboardLayouts.register(
  myCustomLayout,
  displayName: 'Esperanto',
  nativeName: 'Esperanto',
  shortLabel: 'EO',
);
```

Once registered, custom layouts can be referenced by ID in `enabledLayouts` and `defaultLayout`.

### Long-Press Accents

Character keys can define alternate accented characters via `KeyData.char`:

```dart
KeyData.char('e', alternates: ['é', 'è', 'ê', 'ë'])
```

Long-pressing the key reveals an interactive accent bubble callout above the key. Tapping an alternate inserts it directly into the active text field.

---

## Customization

### Themes

Choose between built-in presets or inherit colors and typography from your application's `ThemeData`:

```dart
// Built-in presets
VKeyboardScope(
  theme: VKeyboardTheme.light(accentColor: Colors.teal),
  child: child!,
);

// Built-in dark preset with custom active modifier styling
VKeyboardScope(
  theme: VKeyboardTheme.dark(accentColor: Colors.blue).copyWith(
    activeKeyColor: Colors.blue,
    activeForegroundColor: Colors.white,
  ),
  child: child!,
);

// Ambient ThemeData inheritance (with native OS font fallback stack)
VKeyboardScope(
  theme: VKeyboardTheme.fromTheme(Theme.of(context)),
  child: child!,
);
```

### Runtime Configuration

Adjust keyboard behavior and clipboard limits through `VKeyboardConfig`:

```dart
VKeyboardScope(
  config: const VKeyboardConfig(
    hideOnDone: true,
    moveFocusOnNext: true,
    closeOnOutsideTap: true,
    enableLongPressDelete: true,
    enableKeyRepeat: true,
    enableClipboardHistory: true,
    maxClipboardHistoryItems: 50,
  ),
  child: child!,
);
```

### Custom Layouts

Define custom layouts declaratively without modifying package internals:

```dart
final greekLayout = KeyboardLayout(
  id: 'greek',
  initialPage: 'main',
  pages: {
    'main': [
      'αβγδεζηθ'.split('').map(KeyData.char).toList(),
      'ικλμνξοπ'.split('').map(KeyData.char).toList(),
      [
        KeyData.shift(flex: 1.5),
        ...'ρστυφχψ'.split('').map(KeyData.char),
        KeyData.backspace(flex: 1.5),
      ],
      [
        KeyData.space(flex: 5),
        KeyData.enter(flex: 2),
      ],
    ],
  },
);

VTextField(
  keyboardType: VKeyboardType.custom,
  customLayout: greekLayout,
);
```

### Custom Keys

Insert custom widget keys using `KeyData.custom`:

```dart
KeyData.custom(
  builder: (context) => Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.amber.shade200,
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(Icons.mic, size: 20),
  ),
  text: '[voice]',
  flex: 1.2,
);
```

### Desktop Keyboard & Form Factors

`flutter_v_keyboard` supports both an overlay desktop keyboard via `VKeyboardType.desktop` and the edge-to-edge `DesktopFullKeyboard` widget with 6 physical form-factor presets.

#### Form-Factor Presets (`KeyboardLayoutType`)

| Preset | Label | Rows / Width | Layout & Key Features |
| :--- | :--- | :--- | :--- |
| `KeyboardLayoutType.layout60` | `60% Compact` | 5 rows (`15u`) | Pure number + alphanumeric cluster with `Fn` layer for `Esc`, `F1`–`F12`, `Del`, navigation, and `W`/`A`/`S`/`D` arrows |
| `KeyboardLayoutType.layout65` | `65% Compact` | 5 rows (`16u`) | Number row + alphanumeric + right 1-column navigation strip (`Del`, `PgUp`, `PgDn`, `Home`) + integrated arrows |
| `KeyboardLayoutType.layout75` | `75% Compact` | 6 rows (`16u`) | Top F-row + right 1-column navigation strip + arrows tucked cleanly under Right Shift (no Numpad) |
| `KeyboardLayoutType.layout87TKL` | `87% TKL` | 6 rows (`18u`) | Tenkeyless layout with full alphanumeric, F-row, 3×2 navigation cluster, and Inverted-T arrows (no Numpad) |
| `KeyboardLayoutType.layout98` | `98% Compact` | 6 rows (`19u`) | Compact 1800-style layout with zero inter-cluster gap, tucked arrows, and 4-column Numpad |
| `KeyboardLayoutType.layout100` | `100% Full-Size` | 6 rows (`22u`) | Full desktop ANSI grid: Alphanumeric (`15u`) + Navigation (`3u`) + 4-column Numpad (`4u`) |

#### 1. Automatic via `VKeyboardScope` (`desktopFormFactor`)

Set `desktopFormFactor` in `VKeyboardConfig` to automatically render `DesktopFullKeyboard` whenever a `VTextField(keyboardType: VKeyboardType.desktop)` gains focus:

```dart
VKeyboardScope(
  config: const VKeyboardConfig(
    desktopFormFactor: KeyboardLayoutType.layout87TKL,
    enabledLocales: VKeyboardLocale.values,
  ),
  child: child!,
);

// Inside a page:
VTextField(
  controller: _desktopTextController,
  keyboardType: VKeyboardType.desktop,
);
```

When `desktopFormFactor` is `null` (default), `VKeyboardScope` renders the built-in OSK desktop grid via `KeyboardView`.

#### 2. Embedded or Standalone `DesktopFullKeyboard`

Embed `DesktopFullKeyboard` directly inside any desktop page (with optional `VKeyboardController` binding, or standalone using key callbacks):

```dart
DesktopFullKeyboard(
  layoutType: KeyboardLayoutType.layout100,
  platform: DesktopKeyboardPlatform.fromTargetPlatform(Theme.of(context).platform),
  layoutId: 'en_US', // Switchable at runtime across all 15 built-in locales
  isFullWidth: true, // Stretches edge-to-edge across the monitor; set false for natural width
  maxWidth: 1200, // Optional width cap for compact presets on ultrawide monitors
  showNumpad: true,
  showFunctionRow: true,
  showPlatformToggle: true, // Shows live [Windows | macOS] switcher in header
  showLocaleSelector: true, // Shows 🌐 picker pill in header + Spacebar long-press
  showCandidateBar: true, // Auto-renders CJK CandidateBar when composing with VKeyboardController
  themeData: DesktopKeyboardThemeData.dark(), // Also supports .light() and .fromVKeyboardTheme(...)
  controller: controller, // Optional: links directly to VTextField & IME engines
  onPlatformChanged: (os) => debugPrint('OS switched: $os'),
  onLayoutChanged: (id) => debugPrint('Locale switched: $id'),
  onKeyPressed: (key) => debugPrint('Typed: $key'),
  onSpecialKeyPressed: (action) => debugPrint('Action: $action'),
  onShortcutTriggered: (combo) => debugPrint('Shortcut: $combo'), // e.g. Ctrl+A, Cmd+Shift+Z
);
```

- **Windows vs macOS (`DesktopKeyboardPlatform`)**: Switch between `DesktopKeyboardPlatform.windows` (`Ctrl`, `Win`, `Alt`, `AltGr`, `Menu`, `Backspace`, `Enter`, `PrtSc`, `Num`) and `DesktopKeyboardPlatform.macos` (`fn`, `⌃ control`, `⌥ option`, `⌘ command`, `delete`, `return`, `F13`–`F15`, `clear`). Built-in shortcuts include `Ctrl+...` and `Cmd+A/C/X/V`.
- **Edge-to-Edge & Ultrawide Sizing**: Every key uses `Expanded(flex: N)` proportional units, while `maxKeyboardHeightRatio` (default `0.38`) bounds vertical height cleanly on 1080p, 1440p, and 4K screens.

#### Desktop Shortcuts (`VKeyboardShortcuts`)

Bind custom global shortcuts and OS-level key callbacks for desktop targets:

```dart
VKeyboardShortcuts(
  shortcuts: {
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS): () {
      debugPrint('Save command invoked');
    },
  },
  onMedia: (intent) => debugPrint('Media key: $intent'),
  onMetaKey: () => debugPrint('Meta / Windows key tapped'),
  onMenuKey: () => debugPrint('Context menu key tapped'),
  child: child!,
);
```

### Sensitive Fields

Exclude sensitive information from clipboard history by setting `sensitive: true`:

```dart
VTextField(
  controller: _pinController,
  keyboardType: VKeyboardType.pin,
  sensitive: true, // Content will never be recorded to clipboard history
);
```

---

## Architecture

`flutter_v_keyboard` is designed around single-responsibility layers:

| Component | Responsibility |
| :--- | :--- |
| `VKeyboardScope` | Injects keyboard overlay, manages bottom safe-area insets (`viewInsets.bottom`), and handles tap-outside dismissal. |
| `VKeyboardController` | Coordinates keyboard state, page switches, active modifiers, and clipboard history. |
| `KeyboardSession` | Links the focused `VTextField` to the controller, synchronizing selection and cursor updates. |
| `TextInputEngine` | Core text manipulation engine handling insertions, deletions, formatters, and length constraints. |
| `KeyboardView` | Computes responsive layout metrics and renders mobile/compact keys with per-key repaint boundaries. |
| `DesktopFullKeyboard` | Renders edge-to-edge proportional desktop presets (`60%`–`100%`) with Windows/macOS conventions and desktop locale switching. |
| `CandidateBar` | Displays live offline IME candidate suggestions (`zh_CN`, `zh_TW`, `ja_JP`) above the keyboard during CJK composition. |
| `ClipboardHistoryManager` | Records snippets, enforces storage limits, handles pinning, and syncs with system clipboard. |
| `VKeyboardTheme` | Defines visual colors, elevation, border radii, and system font fallback stacks. |
| `VKeyboardConfig` | Controls runtime keyboard behavior flags and feature toggles. |
| `VKeyboardLayouts` | Global registry for built-in and custom locale layouts, AltGr character mappings, and locale metadata. |
| `LayoutSelectionStorage` | Persists user's selected layout across app sessions (file-backed or in-memory). |

---

## Platform Support

| Platform | Support | Status |
| :--- | :---: | :--- |
| **Android** | Supported | Verified via automated widget tests and example runner. |
| **iOS** | Supported | Verified via automated widget tests and example runner. |
| **macOS** | Supported | Verified via automated widget tests, integration tests, and desktop example. |
| **Windows** | Supported | Verified via automated widget tests and desktop example. |
| **Linux** | Supported | Verified via automated widget tests and desktop example. |
| **Web** | Supported | Verified via automated widget tests and Chrome target (storage runs in-memory). |

### SDK Requirements
- **Flutter**: `>=3.22.0`
- **Dart**: `>=3.4.0 <4.0.0`

---

## Contributing & Links

- **Example App**: Explore [`example/lib/main.dart`](example/lib/main.dart) for a comprehensive demonstration of all layouts, themes, and interactions.
- **Changelog**: Review recent updates and breaking changes in [`CHANGELOG.md`](CHANGELOG.md).
- **Issue Tracker**: Report bugs or propose new features on [GitHub Issues](https://github.com/tegarnugroho/v_keyboard/issues).
- **License**: Released under the [MIT License](LICENSE).
