## 0.3.4

- **Consistent Keyboard Height Across Layouts (`KeyboardMetrics.desktopBaselineHeight`)**:
  - Unified height calculation on tablet and desktop viewports across all non-F-row layouts (`Standard`, `Email`, `URL`, `Password`, `Multiline`, `Number`, `Decimal`, `Phone`, `PIN`, and 5-row desktop presets `layout60`/`layout65`) so dialogs and forms never shift vertically when switching field types.
  - Preserved extra proportional height for expert 6-row layouts displaying the Function row (`layout75`, `layout87TKL`, `layout98`, `layout100`) and utility panels (`ClipboardHistoryPanel`).

## 0.3.3

- **Unified Dark Theme Across Desktop & Mobile Layouts**:
  - Updated `VKeyboardTheme.dark()` (and dark presets via `VKeyboardTheme.fromTheme`) to share the same deep-slate palette as `DesktopFullKeyboard` (`#13151B` background, `#21242D` character keycaps, `#1A1D26` special/modifier keycaps, `#2B3140` 1px key borders, `#1E2330` top hairline border, `#353C4E` pressed highlight, `#2B303E` hover color, `#94A3B8` sub-labels, and `BorderRadius.circular(6)`).
  - Added optional `keyBorderColor`, `containerBorderColor`, `hoverKeyColor`, and `enterKeyColor` tokens to `VKeyboardTheme` and updated `VirtualKey`, `KeyboardView`, `EmojiPanel`, `ClipboardHistoryPanel`, and `VKeyboardLayoutPickerPanel` to render crisp borders, accent-tinted Enter/Action keys, and hairline top borders via `foregroundDecoration`.
  - Updated `VKeyboardScope` to derive `DesktopKeyboardThemeData.fromVKeyboardTheme(theme)` so `accentColor` and `borderRadius` stay synchronized between desktop and non-desktop layouts.
- **Desktop Bottom Utility Bar (Non-Desktop Parity) & Inline Clipboard**:
  - Replaced the standalone dismiss pill on `DesktopFullKeyboard` with a bottom utility bar matching `KeyboardView`: bottom-left close arrow (`showHideKeyboardButton`), optional bottom-left language globe (`showGlobeKey`), and bottom-right clipboard trigger (`showClipboardButton`), plus `hideIcon`, `globeIcon`, `clipboardIcon`, `onClipboardTap`, and `bottomSafeArea`.
  - Derives bottom-bar defaults automatically from `VKeyboardController.config` and switches cleanly in-place to `ClipboardHistoryPanel` when opening clipboard history in embedded layouts.
  - Wired `VKeyboardScope` (`VKeyboardConfig.desktopFormFactor`) to display the bottom utility bar (`onDismiss: controller.hide`, clipboard trigger, and `_fullKeyboardMetrics` height parity).
- **Documentation & Example App**:
  - Documented `DesktopFullKeyboard`, the 6 `KeyboardLayoutType` presets (`layout60`–`layout100`), `DesktopKeyboardPlatform` (Windows/macOS), `VKeyboardConfig.desktopFormFactor`, and the bottom utility bar in `README.md`.
  - Updated the example app's Desktop Keyboard tab with interactive hide/reopen and inline clipboard history switching.

## 0.3.2

- **`DesktopFullKeyboard` Widget (Edge-to-Edge Responsive Desktop OSK)**:
  - Added the edge-to-edge desktop virtual keyboard widget powered by proportional `Expanded(flex: N)` keycaps and `LayoutBuilder` height/typography scaling from narrow windows (`480x800`) to ultrawide & 4K monitors (`3440x1440`, `3840x2160`).
  - Added 6 hardware form-factor presets via `KeyboardLayoutType`: `layout60` (pure alphanumeric + `Fn` layer for F-keys, Delete, and arrows), `layout65`, `layout75`, `layout87TKL`, `layout98` (1800-compact with zero inter-cluster gap), and `layout100` (Full-Size with Main `15u`, Navigation `3u`, and 4-column Numpad `4u`).
  - Exposed modular building blocks (`KeyModel`, `KeyType`, `VirtualKeyAction`, `DesktopFullLayoutData`, `VirtualKeyButton`, and `DesktopKeyboardThemeData` with `.dark()`, `.light()`, and `.fromVKeyboardTheme()` presets).
  - Supports LED status indicators (`FN`, `CAPS`, `NUM`), key-repeat, hover/press visual feedback, `isFullWidth` / `maxWidth` / `maxKeyboardHeightRatio` constraints, `onKeyPressed`, `onSpecialKeyPressed`, `onShortcutTriggered`, and optional `VKeyboardController` / `VKeyboardScope` binding.
  - Added `VKeyboardConfig.desktopFormFactor` so `VKeyboardScope` can automatically render `DesktopFullKeyboard` with the chosen preset when `VKeyboardType.desktop` fields are focused.
- **Windows & macOS Desktop Conventions (`DesktopKeyboardPlatform`)**:
  - Switch between `DesktopKeyboardPlatform.windows` (`Ctrl`, `Win`, `Alt`, `AltGr`, `Menu`, `Backspace`, `Enter`, `PrtSc`, `Num`) and `DesktopKeyboardPlatform.macos` (`fn`, `⌃ control`, `⌥ option`, `⌘ command`, `delete`, `return`, `F13`–`F15`, `clear`) via `platform`, `showPlatformToggle`, and `onPlatformChanged`.
  - Dispatches macOS `Cmd+A/C/X/V` clipboard shortcuts alongside standard `Ctrl`/`Alt`/`Shift` shortcut combos.
- **Multi-Language Desktop Layouts & CJK IME Integration**:
  - Enabled all 15 built-in locales (`en_US`, `en_GB`, `de_DE`, `fr_FR`, `es_ES`, `nordic`, `tr_TR`, `ru_RU`, `el_GR`, `ko_KR`, `ja_JP`, `zh_CN`, `zh_TW`, `th_TH`, `vi_VN`) across all 6 form-factor presets (`60%`–`100%`) and both OS platforms, including `AltGr` mappings and Unicode cased Shift/CapsLock support.
  - Added a taskbar/menubar-style `🌐` locale picker pill (`showLocaleSelector`, `availableLayouts`, `layoutId`, `onLayoutChanged`) with a 2-column desktop selector modal and IME hints, plus active locale Spacebar labels and Spacebar long-press language switching.
  - Integrated automatic `CandidateBar` rendering (`showCandidateBar`) for `zh_CN` (Pinyin), `zh_TW` (Zhuyin), and `ja_JP` (Kana) composition alongside `ko_KR` Hangul and `vi_VN` Telex when connected to `VKeyboardController` / `VTextField`.

## 0.3.1

- **Fix: layout picker did nothing when `VKeyboardScope` sits in `MaterialApp.builder`**:
  - Holding the space bar (or the globe key) called `showDialog` / `showModalBottomSheet` from inside the keyboard. With the recommended `MaterialApp.builder` setup the scope is above the `Navigator`, so the call threw and no picker appeared (with touch and mouse alike).
  - The picker is now rendered by `VKeyboardScope` itself, above the keyboard. It needs no `Navigator`, keeps focus on the active field (so the keyboard stays open), and shares the keyboard's tap region, so tapping it never dismisses the keyboard. Tapping the backdrop closes it without switching.
  - The picker closes automatically when the keyboard hides or the controller is disposed.
- **New API**:
  - `VKeyboardController.openLayoutPicker()` returns a `Future<String?>` with the selected layout id (`null` if dismissed). `closeLayoutPicker([layoutId])` closes it, and `isLayoutPickerOpen` reports its state.
  - `VKeyboardLayoutPickerPanel`: the layout list widget, exposed for custom picker UIs.
- `showVKeyboardLayoutPicker` uses the in-scope picker when called below the owning `VKeyboardScope` and falls back to a dialog / bottom sheet otherwise.

## 0.3.0

- **Multi-Language Keyboard Layouts**:
  - Add 15 built-in locale layouts with localized main and symbol pages:
    - `en_US`: US English QWERTY (default, identical to previous releases).
    - `en_GB`: UK English QWERTY with `£` currency symbol.
    - `de_DE`: German QWERTZ with swapped `Y`/`Z`, `ä`, `ö`, `ü`, `ß`, and `€`.
    - `fr_FR`: French AZERTY with swapped `A`/`Q` and `Z`/`W`, `M` adjacent to `L`, `é`, `è`, `à`, `ç`, `ù`, and `€`.
    - `es_ES`: Spanish QWERTY with `ñ`, `¿`, `¡`, and `€`.
    - `nordic`: Nordic QWERTY with `å`, `ä`, `ö`, `æ`, `ø`, and `€`/`kr`.
    - `tr_TR`: Turkish Q with `ğ`, `ü`, `ş`, `ı`, `ö`, `ç`, `₺`, and strict dotted/dotless casing (`i ↔ İ`, `ı ↔ I`).
    - `ru_RU`: Russian Cyrillic ЙЦУКЕН with `₽`.
    - `el_GR`: Greek layout with Greek alphabet, `€`, and `Ελληνικά (Greek) · GR` label.
    - `ko_KR`: Korean 2-Set Hangul (두벌식) with syllable composition, compound vowels/batchim, and `₩`.
    - `ja_JP`: Japanese JIS Kana with `¥` currency, voicing marks (`゛`, `゜`), and dakuten composition.
    - `zh_CN`: Simplified Chinese Pinyin layout with fullwidth punctuation (`，`, `。`, `、`) and `¥`.
    - `zh_TW`: Traditional Chinese Zhuyin (注音 / Bopomofo) layout with tone marks and Traditional punctuation.
    - `th_TH`: Thai Kedmanee (เกษมณี) layout with independent/dependent vowels, tone marks, Thai numerals, and `฿`.
    - `vi_VN`: Vietnamese Telex QWERTY layout with diacritic alternates, `₫` currency, and Telex composition.
  - Add declarative global registry `VKeyboardLayouts` (`register`, `getLayout`, `allLayouts`, `supportedLocales`, `altGrMapFor`, `isoLayoutIds`, `isLatin`).
- **CJK Offline IME Engines & Candidate Bar**:
  - Pure offline dictionary engines for Simplified Chinese Pinyin (`zh_CN`), Traditional Chinese Zhuyin (`zh_TW`), and Japanese JIS Kana/Kanji (`ja_JP`).
  - Real-time `CandidateBar` widget rendered above the keyboard for candidate selection with numbered shortcuts, tap selection, and space bar commit.
  - Configurable via `VKeyboardConfig.enableImeCandidates` and `maxImeCandidates`.
- **Hangul Syllable Composition Engine (`HangulComposer`)**:
  - Pure algorithmic Unicode Hangul composition (UAX #29 / Hangul Syllable Composition standard: `0xAC00 + (cho * 21 + jung) * 28 + jong`) with zero external dependencies.
  - Real-time syllable combination (e.g. `ㅎ` + `ㅏ` + `ㄴ` = `한`).
  - Compound vowel merging (e.g. `ㅗ` + `ㅏ` = `ㅘ`, `고` + `ㅏ` = `과`).
  - Compound batchim merging (e.g. `ㄹ` + `ㄱ` = `ㄺ`, `달` + `ㄱ` = `닭`).
  - Batchim splitting when a vowel follows (e.g. `간` + `ㅏ` = `가na`, `닭` + `ㅣ` = `달기`).
  - Step-by-step backspace decomposition (e.g. `닭` -> `달` -> `다` -> `ㄷ` -> delete).
- **Kana Voicing Mark Engine (`KanaComposer`)**:
  - Algorithmic dakuten (`゛`) and handakuten (`゜`) sound composer for Japanese typing (e.g. `か` + `゛` = `が`, `は` + `゜` = `ぱ`).
  - Step-by-step backspace decomposition (`が` -> `か`, `ぱ` -> `は`).
- **Vietnamese Telex Engine (`VietnameseTelexComposer`)**:
  - Pure algorithmic Telex syllable composer with circumflex (`aa` -> `â`, `ee` -> `ê`, `oo` -> `ô`), breve/horn (`aw` -> `ă`, `ow` -> `ơ`, `uw`/`w` -> `ư`, `uow` -> `ươ`), and stroke (`dd` -> `đ`).
  - Full tone mark support (`s` sắc, `f` huyền, `r` hỏi, `x` ngã, `j` nặng, `z` remove tone).
  - Modern orthographic tone placement on diphthongs/triphthongs and step-by-step backspace decomposition.
- **Smart Latin Fallback for Email, URL, and Password Fields**:
  - Automatically switches non-Latin layouts (Korean, Japanese, Chinese, Thai, Russian, Greek) to standard Latin QWERTY when typing into `Email`, `URL`, or `Password` fields.
  - Explicit `'English'` space bar label on fallback layouts.
  - Automatic suppression of IME engines and diacritic composers on sensitive and ASCII fields.
- **Space Bar Hold & Runtime Layout Switcher**:
  - Holding (long-pressing) the space bar opens `showVKeyboardLayoutPicker` displaying active selection, localized display names, and short codes (bottom sheet on mobile, dialog on desktop/tablet).
  - Space bar subtly displays the active language name (e.g. `English (US)`, `Deutsch`, `Русский`, `한국어`, `日本語`) when multiple layouts are enabled.
  - Transient space bar announcement banner displaying active layout display name briefly (~1.5s fade out) upon switching.
  - Optional globe key (`Icons.language`) in the bottom bar, configurable via `VKeyboardConfig.showGlobeKey` (defaults to `false`).
  - Screen-reader accessible with semantic announcements via `SemanticsService`.
- **Theming Enhancements**:
  - Added `activeKeyColor` and `activeForegroundColor` to `VKeyboardTheme` for high-contrast active modifier / engaged lock keys (active Shift, Caps Lock, held modifiers) in both light and dark themes.
- **Bottom Bar Clipboard History Button**:
  - Dedicated clipboard history trigger button placed on the far right of the bottom safe-area bar, aligned with the dismiss button, configurable via `VKeyboardConfig.showClipboardButton`.
- **Long-Press Accents**:
  - Character keys support `alternates` via `KeyData.char('e', alternates: ['é', 'è', 'ê', 'ë'])`.
  - Long-pressing letter keys presents an interactive accent callout popup above the key.
  - Fully compatible with key repeat and backspace deletion.
- **Desktop Layout ISO & AltGr Support**:
  - Full desktop keyboard (`VKeyboardType.desktop`) adapts to ISO layout standards with ISO Enter and the extra key beside Left Shift for ISO locales (`en_GB`, `de_DE`, `fr_FR`, `es_ES`, `nordic`, `tr_TR`, `ru_RU`).
  - Locale-specific AltGr character mappings (e.g., `AltGr + Q` → `@`, `AltGr + E` → `€` in `de_DE`).
- **Cross-Platform Layout Selection Persistence**:
  - Saves user's selected keyboard layout across app restarts via `LayoutSelectionStorage` (file-backed on Android, iOS, Windows, macOS, Linux, and in-memory on Web).
- **Reactive Focus & Dynamic Keyboard Type Handling**:
  - `VTextField.didUpdateWidget` dynamically rebuilds and re-attaches `KeyboardSession` when `keyboardType` or other field attributes change while focused.
  - `VKeyboardController.attach` resets the active keyboard page when input types change on the same field.
  - Space bar display name accurately reads from the active layout, resolving stale fallback states.
- **Public API Additions**:
  - `VKeyboardLocale` enum: Type-safe enum for all 15 built-in locale layouts (`enUS`, `enGB`, `deDE`, `frFR`, `esES`, `nordic`, `trTR`, `ruRU`, `elGR`, `koKR`, `jaJP`, `zhCN`, `zhTW`, `thTH`, `viVN`) with `isLatin`, `id`, `displayName`, `shortLabel`, and `fromId()`.
  - `VKeyboardConfig`: `enabledLocales`, `defaultLocale`, `enabledLayouts`, `defaultLayout`, `showGlobeKey`, `showClipboardButton`, `enableImeCandidates`, `maxImeCandidates`, `persistLayoutSelection`, `openPickerOnTap`.
  - `VKeyboardController`: `currentLocale`, `setLocale(locale)`, `currentLayoutId`, `setLayout(id)`, `nextLayout()`, `onLayoutChanged` stream, `insertText(text)`, `composingText`, `candidates`, `commitCandidate(text)`.
  - `VKeyboardTheme`: `activeKeyColor`, `activeForegroundColor`.
  - `CandidateBar`: Horizontal candidate bar widget for IME suggestion selection.
  - `VKeyboardScope`: `onLayoutChanged` callback.
  - `showVKeyboardLayoutPicker`: modal bottom sheet on mobile or centered dialog on desktop/tablet to pick active layout.
- **Example App & Preview Improvements**:
  - Replace floating overlay stack in the embedded preview with in-place page switching for `EmojiPanel` and `ClipboardHistoryPanel`.
  - Synchronize panel heights and bottom safe-area dismiss buttons to ensure smooth transitions with zero vertical shift when opening the emoji panel.
  - Add interactive `VKeyboardLocale` selector chips and demonstration of custom math layout.

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
