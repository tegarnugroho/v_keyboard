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
