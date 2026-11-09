## 0.3.0

- **Multi-Language Keyboard Layouts**:
  - Add 13 built-in locale layouts with localized main and symbol pages:
    - `en_US`: US English QWERTY (default, identical to previous releases).
    - `en_GB`: UK English QWERTY with `£` currency symbol.
    - `de_DE`: German QWERTZ with swapped `Y`/`Z`, `ä`, `ö`, `ü`, `ß`, and `€`.
    - `fr_FR`: French AZERTY with swapped `A`/`Q` and `Z`/`W`, `M` adjacent to `L`, `é`, `è`, `à`, `ç`, `ù`, and `€`.
    - `es_ES`: Spanish QWERTY with `ñ`, `¿`, `¡`, and `€`.
    - `nordic`: Nordic QWERTY with `å`, `ä`, `ö`, `æ`, `ø`, and `€`/`kr`.
    - `tr_TR`: Turkish Q with `ğ`, `ü`, `ş`, `ı`, `ö`, `ç`, `₺`, and strict dotted/dotless casing (`i ↔ İ`, `ı ↔ I`).
    - `ru_RU`: Russian Cyrillic ЙЦУКЕН with `₽`.
    - `el_GR`: Greek layout with Greek alphabet and `€`.
    - `ko_KR`: Korean 2-Set Hangul (두벌식) with syllable composition, compound vowels/batchim, and `₩`.
    - `ja_JP`: Japanese JIS Kana with `¥` currency, voicing marks (`゛`, `゜`), and dakuten composition.
    - `zh_CN`: Simplified Chinese Pinyin layout with fullwidth punctuation (`，`, `。`, `、`) and `¥`.
    - `zh_TW`: Traditional Chinese Zhuyin (注音 / Bopomofo) layout with tone marks and Traditional punctuation.
  - Add declarative global registry `VKeyboardLayouts` (`register`, `getLayout`, `allLayouts`, `supportedLocales`, `altGrMapFor`, `isoLayoutIds`).
- **Hangul Syllable Composition Engine (`HangulComposer`)**:
  - Pure algorithmic Unicode Hangul composition (UAX #29 / Hangul Syllable Composition standard: `0xAC00 + (cho * 21 + jung) * 28 + jong`) with zero external dependencies.
  - Real-time syllable combination (e.g. `ㅎ` + `ㅏ` + `ㄴ` = `한`).
  - Compound vowel merging (e.g. `ㅗ` + `ㅏ` = `ㅘ`, `고` + `ㅏ` = `과`).
  - Compound batchim merging (e.g. `ㄹ` + `ㄱ` = `ㄺ`, `달` + `ㄱ` = `닭`).
  - Batchim splitting when a vowel follows (e.g. `간` + `ㅏ` = `가나`, `닭` + `ㅣ` = `달기`).
  - Step-by-step backspace decomposition (e.g. `닭` -> `달` -> `다` -> `ㄷ` -> delete).
- **Kana Voicing Mark Engine (`KanaComposer`)**:
  - Algorithmic dakuten (`゛`) and handakuten (`゜`) sound composer for Japanese typing (e.g. `か` + `゛` = `が`, `は` + `゜` = `ぱ`).
  - Step-by-step backspace decomposition (`が` -> `か`, `ぱ` -> `は`).
- **Space Bar Hold & Runtime Layout Switcher**:
  - Holding (long-pressing) the space bar opens `showVKeyboardLayoutPicker` displaying active selection, localized display names, and short codes (bottom sheet on mobile, dialog on desktop/tablet).
  - Space bar subtly displays the active language name (e.g. `English (US)`, `Deutsch`, `Русский`) when multiple layouts are enabled.
  - Transient space bar announcement banner displaying active layout display name briefly (~1.5s fade out) upon switching.
  - Optional globe key (`Icons.language`) in the bottom bar, configurable via `VKeyboardConfig.showGlobeKey` (defaults to `false`).
  - Screen-reader accessible with semantic announcements via `SemanticsService`.
- **Long-Press Accents**:
  - Character keys support `alternates` via `KeyData.char('e', alternates: ['é', 'è', 'ê', 'ë'])`.
  - Long-pressing letter keys presents an interactive accent callout popup above the key.
  - Fully compatible with key repeat and backspace deletion.
- **Desktop Layout ISO & AltGr Support**:
  - Full desktop keyboard (`VKeyboardType.desktop`) adapts to ISO layout standards with ISO Enter and the extra key beside Left Shift for ISO locales (`en_GB`, `de_DE`, `fr_FR`, `es_ES`, `nordic`, `tr_TR`, `ru_RU`).
  - Locale-specific AltGr character mappings (e.g., `AltGr + Q` → `@`, `AltGr + E` → `€` in `de_DE`).
- **Cross-Platform Layout Selection Persistence**:
  - Saves user's selected keyboard layout across app restarts via `LayoutSelectionStorage` (file-backed on Android, iOS, Windows, macOS, Linux, and in-memory on Web).
- **Public API Additions**:
  - `VKeyboardLocale` enum: Type-safe enum for all 9 built-in locale layouts (`enUS`, `enGB`, `deDE`, `frFR`, `esES`, `nordic`, `trTR`, `ruRU`, `elGR`) with `id`, `displayName`, `shortLabel`, and `fromId()`.
  - `VKeyboardConfig`: `enabledLocales`, `defaultLocale`, `enabledLayouts`, `defaultLayout`, `showGlobeKey`, `persistLayoutSelection`, `openPickerOnTap`.
  - `VKeyboardController`: `currentLocale`, `setLocale(locale)`, `currentLayoutId`, `setLayout(id)`, `nextLayout()`, `onLayoutChanged` stream, `insertText(text)`.
  - `VKeyboardScope`: `onLayoutChanged` callback.
  - `showVKeyboardLayoutPicker`: modal bottom sheet on mobile or centered dialog on desktop/tablet to pick active layout.
- **Example App & Preview Improvements**:
  - Replace floating overlay stack in the embedded preview with in-place page switching for `EmojiPanel` and `ClipboardHistoryPanel`.
  - Synchronize panel heights and bottom safe-area dismiss buttons to ensure smooth transitions with zero vertical shift when opening the emoji panel.
  - Add interactive `VKeyboardLocale` selector chips.

## 0.2.4

- **Gboard-Style Dismiss Arrow**:
  - Add a downward arrow button (`Icons.keyboard_arrow_down_rounded`) below the keyboard grid in `KeyboardView` (like Google Keyboard / Gboard) to dismiss/close the virtual keyboard.
  - Configurable via `VKeyboardConfig.showHideKeyboardButton` (default: `true`), automatically omitted on desktop layouts.
  - Accurately synchronizes bottom bar height with `VKeyboardScope`'s safe area insets and `viewInsets.bottom` so focused text fields remain properly visible above the keyboard.
  - Add dismiss button support across `EmojiPanel` and `ClipboardHistoryPanel` bottom safe area areas.
  - Support custom `hideIcon` and `onHide` callback in `KeyboardView`.
- **`VKeyboardType` Enum with Value**:
  - Add `label` property to `VKeyboardType` enum (`standard('QWERTY')`, `decimal('Decimal')`, etc.) for type-safe, human-readable display names.
- **Example App & Bug Fixes**:
  - Fix `DropdownButton` assertion error when selecting `Decimal`, `URL`, or `Password` keyboard types by switching the preview dropdown to strictly typed `DropdownButton<VKeyboardType>`.
  - Fix example app initial state opening the clipboard panel on first launch by defaulting `_showClipboardInPreview` to `false`.

## 0.2.3

- **Scroll-into-view improvement**:
  - Restrict automatic focus scroll-into-view (`_scrollIntoView`) in `VTextField` to vertical ancestor `Scrollable`s only.
  - Fixes unwanted horizontal displacement and snapping when focusing input fields inside horizontal scroll containers such as `TabBarView`, `PageView`, or carousels.
  - Preserves vertical scrolling behavior for fields obscured by the on-screen keyboard within vertical scroll views.

## 0.2.2
- Use absolute image URLs in the README so the showcase renders on pub.dev.

## 0.2.1

- **OS Clipboard Synchronization**:
  - Automatically synchronize clipboard history with host operating system clipboard across Android, iOS, macOS, Windows, Linux, and Web via `ClipboardHistoryManager.syncFromSystemClipboard()`.
  - Copy and cut shortcuts (`Cmd+C`, `Ctrl+C`, `Cmd+X`, `Ctrl+X`) seamlessly populate system clipboard and history.
  - Add `VKeyboardConfig.syncSystemClipboard` configuration toggle.
- **Virtual Keyboard Clipboard Trigger**:
  - Add small, subtle clipboard history icon key directly into virtual keyboard layouts (`123`/symbols page and desktop cluster) without altering keyboard height.
  - Accessible semantic label and tooltip for clipboard key actions.
- **UI & Experience Polish**:
  - Modernized `ClipboardHistoryPanel` with refined typography, professional icon set, item counter badge, and quick filter chips (`All`, `Pinned`, `Recent`).
  - High-contrast visual styling and robust system font fallback stacks across light and dark themes.
- **Bug Fixes & Reliability**:
  - Fix framework locked widget tree assertion: defer `setState()` in `VKeyboardScope` during unmount and persistent callback phases.
  - Export `ClipboardHistoryPanel` and `EmojiPanel` directly in package public exports.
- **Showcase & Example App**:
  - Redesigned example app with macOS-style window framing, interactive playground, floating clipboard preview, and full-screen desktop keyboard view.
  - Update all showcase screenshots in README with latest high-resolution app captures.

## 0.2.0

- **Clipboard History (`Win + V` style)**:
  - Add `ClipboardHistoryManager` with `record()`, `togglePin()`, `deleteItem()`, `clearUnpinned()`, `clearAll()`, and `search()`.
  - Add cross-platform persistence with `ClipboardHistoryStorage` (file-backed on Android, iOS, Windows, macOS, Linux, and in-memory on Web).
  - Add dedicated `ClipboardHistoryPanel` UI with search filtering, 2-line visual preview, relative timestamps, pin/unpin toggles, delete action, and clear confirmation.
  - Add keyboard entry points: clipboard key on `123`/symbols page, emoji panel bottom bar, and desktop cluster.
  - Add hardware keyboard shortcuts: `Win + V` and `Ctrl + Shift + V` on `VTextField`.
  - Add `VKeyboardConfig.enableClipboardHistory` and `VKeyboardConfig.maxClipboardHistoryItems`.
  - Add privacy and sensitive field protection: excludes `obscureText`, `VKeyboardType.password`, `VKeyboardType.pin`, and `VTextField(sensitive: true)` from history recording.
  - Integrate with `TextInputEngine` pipeline, respecting `maxLength`, `inputFormatters`, `readOnly`, and selection replacement.

## 0.1.2

- Add built-in `VKeyboardTheme.light()` and `VKeyboardTheme.dark()` presets.
- Add `VKeyboardType.text` for a standard QWERTY layout without the emoji key.

## 0.1.1

- Use absolute image URLs in the README so the showcase renders on pub.dev.

## 0.1.0

Initial release.

- `VTextField` — a drop-in, `TextField`-compatible field driven by an on-screen
  keyboard (no OS keyboard), with real cursor, selection, multiline editing and
  full Flutter focus integration.
- `VKeyboardScope` — hosts the keyboard, animates it in/out and pushes content
  like the system keyboard (`viewInsets`).
- Built-in layouts: standard, number, decimal, phone, pin, password, email,
  url, multiline, emoji, full **desktop** (Windows OSK style) and custom.
- Desktop module: modifiers (Shift/Ctrl/Alt/AltGr/Meta), Caps/Num/Scroll Lock,
  navigation (arrows, Home/End/Page, by-word), built-in + custom shortcuts
  (`VKeyboardShortcuts`), clipboard (Ctrl+A/C/X/V), key repeat, hover/locked
  visuals, and native Windows keys via FFI (Print Screen, media, Win/Menu).
- Scrollable, categorised emoji panel (zero runtime dependency).
- Responsive sizing for phone/tablet/desktop and resizable windows; Material 3
  theming via `VKeyboardTheme`; behaviour via `VKeyboardConfig`.
- Hardware-keyboard fallback on desktop/web; accessibility semantics.
- Unit + widget tests; comprehensive example app.
