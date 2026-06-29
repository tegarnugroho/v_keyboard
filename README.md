# v_keyboard

A fully customizable, **native-feeling** virtual keyboard and text-input system
for Flutter — Android, iOS, Windows, macOS, Linux and Web.

It is not just a keyboard widget: `VirtualTextField` is a drop-in replacement
for `TextField` that integrates with Flutter's focus system and is driven by an
on-screen keyboard instead of the OS keyboard.

## Highlights

- Appears on focus, hides on blur — follows `FocusNode` naturally.
- Real cursor, selection, selection-replacement and multiline editing
  (built on a `readOnly` `TextField`, so it behaves natively).
- Pushes the UI up like the system keyboard (injects `viewInsets.bottom`).
- Long-press backspace + held-key repeat.
- Temporary shift, caps-lock (double-tap), `ABC / 123 / #+=` pages.
- Built-in layouts: standard, number, decimal, phone, pin, password, email,
  url, multiline, and fully **custom**.
- Full `TextInputAction` support (next/previous/done/go/search/send/newline…)
  respecting `FocusTraversalPolicy`.
- Responsive sizing for phone/tablet/desktop, portrait/landscape, resizable
  windows — heights are computed, never hard-coded; centred + width-limited on
  large desktop windows.
- Hardware-keyboard fallback on desktop/web.
- Per-key repaint (taps don't rebuild the whole keyboard), `RepaintBoundary`s,
  `ValueNotifier`-based pressed state.
- Material theming via `VirtualKeyboardTheme`, behaviour via
  `VirtualKeyboardConfig`. Semantics for screen readers.

## Quick start

Wrap your app once:

```dart
MaterialApp(
  builder: (context, child) => VirtualKeyboardScope(child: child!),
  home: MyPage(),
);
```

Use `VirtualTextField` like a `TextField`:

```dart
VirtualTextField(
  controller: controller,
  focusNode: focusNode,
  keyboardType: VirtualKeyboardType.standard, // note: `default` is reserved
  textInputAction: TextInputAction.next,
  onSubmitted: (value) {},
)
```

> **Naming note:** Dart reserves the word `default`, so the standard
> alphanumeric keyboard is `VirtualKeyboardType.standard`.

## Custom layouts

```dart
final layout = KeyboardLayout(
  id: 'greek',
  initialPage: 'main',
  pages: {
    'main': [
      'αβγδε'.split('').map(KeyData.char).toList(),
      [KeyData.shift(), KeyData.space(), KeyData.backspace(), KeyData.enter()],
    ],
  },
);

VirtualTextField(
  keyboardType: VirtualKeyboardType.custom,
  customLayout: layout,
);
```

Custom keys (emoji/clipboard/voice/etc.) via `KeyData.custom(builder)` — no need
to fork the package.

## Configuration

```dart
VirtualKeyboardScope(
  config: VirtualKeyboardConfig(
    hideOnDone: true,
    moveFocusOnNext: true,
    closeOnOutsideTap: true,
    enableLongPressDelete: true,
    enableKeyRepeat: true,
  ),
  theme: VirtualKeyboardTheme.fromTheme(Theme.of(context)),
  child: ...,
);
```

## Architecture

Cleanly separated, single-responsibility units:

| Concern           | Type                          |
|-------------------|-------------------------------|
| Orchestration     | `VirtualKeyboardController`    |
| Per-field session | `KeyboardSession`             |
| Pure text editing | `TextInputEngine`             |
| Layouts/keys      | `KeyboardLayout`, `KeyData`, `BuiltinLayouts` |
| Actions           | `KeyboardActionHandler`       |
| Responsive sizing | `KeyboardMetrics`             |
| Rendering         | `KeyboardView`, `KeyboardKey` |
| Theme / config    | `VirtualKeyboardTheme`, `VirtualKeyboardConfig` |
| Host + insets     | `VirtualKeyboardScope`        |

See [`example/`](example/lib/main.dart) for a full demo of every layout, a
custom layout, and the action callbacks.

## Desktop keyboard (Windows OSK style)

`VirtualKeyboardType.desktop` renders a full physical keyboard: function row,
number row, full QWERTY, all modifiers (Ctrl/Alt/AltGr/Win/Menu, L+R Shift/Ctrl),
Caps/Num/Scroll Lock, navigation cluster (arrows, Home/End, Page Up/Down,
Insert/Delete), a numeric keypad and optional media keys. It is **responsive by
width** — sections collapse as the window narrows (media → numpad → function row),
typing keys always remain.

```dart
VirtualTextField(
  keyboardType: VirtualKeyboardType.desktop,
  maxLines: 5,
)
```

Supported behaviour: Shift/Caps casing, Ctrl/Alt/Meta modifier combos,
Shift+Arrow (extend selection), Ctrl+Arrow (by word), Home/End/PageUp/PageDown,
Ctrl+Backspace/Delete (word), built-in Ctrl+A/C/X/V clipboard, key repeat, and
hover/pressed/locked visual feedback.

Register custom shortcuts and desktop callbacks with `VirtualKeyboardShortcuts`:

```dart
VirtualKeyboardShortcuts(
  shortcuts: {
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS): save,
  },
  onMedia: (intent) => player.handle(intent),
  onMetaKey: () => openStartMenu(),
  clipboardCallbacks: ClipboardCallbacks(onPaste: () => myPaste()),
  child: ...,
)
```

Desktop architecture (separate from mobile, shared controller/engine/focus):
`KeyboardModifierController`, `KeyboardNavigation`, `KeyboardShortcutManager`,
`ClipboardActions`, `DesktopLayouts`. Replace the whole layout (compact / gaming
/ POS / kiosk) by passing a `customLayout` with `VirtualKeyboardType.desktop` or
`.custom`.

## Status

Production-oriented foundation with unit + widget tests
(`flutter test`). See `CHANGELOG`/issues for the remaining roadmap items
(emoji page UI, floating/docked desktop polish, integration tests).
