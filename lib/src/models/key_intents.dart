import 'package:flutter/services.dart';

/// Momentary modifier keys (sticky-toggle on the virtual keyboard).
enum ModifierKey { shift, control, alt, altGr, meta }

/// Lock keys whose state persists until toggled again.
enum LockKey { capsLock, numLock, scrollLock }

/// Cursor / selection movement intents for navigation keys.
enum NavIntent {
  left,
  right,
  up,
  down,
  home,
  end,
  pageUp,
  pageDown,
}

/// Clipboard intents.
enum ClipboardIntent { copy, cut, paste, selectAll }

/// Optional media intents (delivered to a developer callback).
enum MediaIntent { playPause, stop, volumeUp, volumeDown, mute, next, previous }

/// Maps a [ModifierKey] to the generic (synonym) [LogicalKeyboardKey] used when
/// building a [LogicalKeySet] for shortcut matching, so developer-declared
/// shortcuts using `LogicalKeyboardKey.control` etc. match.
extension ModifierKeyLogical on ModifierKey {
  LogicalKeyboardKey get logicalKey => switch (this) {
        ModifierKey.shift => LogicalKeyboardKey.shift,
        ModifierKey.control => LogicalKeyboardKey.control,
        ModifierKey.alt => LogicalKeyboardKey.alt,
        ModifierKey.altGr => LogicalKeyboardKey.altRight,
        ModifierKey.meta => LogicalKeyboardKey.meta,
      };
}
