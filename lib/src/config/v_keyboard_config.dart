import 'package:flutter/widgets.dart';

/// Behavioural configuration for the virtual keyboard.
///
/// Applied at the [VKeyboardScope] level and overridable per
/// [VTextField].
@immutable
class VKeyboardConfig {
  const VKeyboardConfig({
    this.hideOnDone = true,
    this.submitOnDone = true,
    this.moveFocusOnNext = true,
    this.moveFocusOnPrevious = true,
    this.closeOnOutsideTap = true,
    this.maintainFocusOnSearch = true,
    this.enableLongPressDelete = true,
    this.enableKeyRepeat = true,
    this.autoShiftFirstLetter = true,
    this.hardwareKeyboardFallback = true,
    this.numericActionKey = true,
    this.scrollFocusedIntoView = true,
    this.longPressDeleteDelay = const Duration(milliseconds: 350),
    this.keyRepeatDelay = const Duration(milliseconds: 400),
    this.keyRepeatInterval = const Duration(milliseconds: 55),
    this.animationDuration = const Duration(milliseconds: 230),
    this.animationCurve = Curves.easeOutCubic,
    this.enableClipboardHistory = true,
    this.maxClipboardHistoryItems = 50,
    this.syncSystemClipboard = true,
    this.showHideKeyboardButton = true,
    this.enabledLayouts = const ['en_US'],
    this.defaultLayout,
    this.showGlobeKey = false,
    this.persistLayoutSelection = true,
    this.openPickerOnTap = true,
  });

  /// Enabled layout IDs for switching via space bar hold or the globe key.
  ///
  /// Defaults to `['en_US']`. When 2 or more layouts are enabled, holding
  /// (long-pressing) the space bar opens the layout picker dialog/bottom sheet.
  final List<String> enabledLayouts;

  /// The initial layout to use before any selection is made.
  ///
  /// Defaults to the first layout in [enabledLayouts] or `'en_US'`.
  final String? defaultLayout;

  /// Whether to display the optional globe (layout switcher) key in the bottom bar.
  ///
  /// Defaults to `false`. By default, users switch layouts by holding
  /// (long-pressing) the space bar, matching modern on-screen keyboard UX.
  final bool showGlobeKey;

  /// Whether to persist the selected layout across app restarts using local storage.
  final bool persistLayoutSelection;

  /// Whether tapping the globe key opens the layout picker dialog/bottom sheet
  /// directly instead of cycling to the next layout.
  ///
  /// Defaults to `true`.
  final bool openPickerOnTap;

  /// Whether clipboard history recording and the clipboard panel are enabled.
  final bool enableClipboardHistory;

  /// Maximum number of unpinned items to preserve in clipboard history.
  final int maxClipboardHistoryItems;

  /// Whether to automatically synchronize with the operating system clipboard
  /// across all platforms (Android, iOS, macOS, Windows, Linux, Web).
  final bool syncSystemClipboard;

  /// Whether to show a downward arrow button below the keyboard (like
  /// Google Keyboard / Gboard) to dismiss/close the keyboard.
  final bool showHideKeyboardButton;

  /// Hide the keyboard when a `done`/`go`/`send` action fires.
  final bool hideOnDone;

  /// Invoke `onSubmitted`/`onEditingComplete` on `done`.
  final bool submitOnDone;

  /// Move focus to the next field on a `next` action.
  final bool moveFocusOnNext;

  /// Move focus to the previous field on a `previous` action.
  final bool moveFocusOnPrevious;

  /// Unfocus (and hide) when the user taps outside the field and keyboard.
  final bool closeOnOutsideTap;

  /// Keep the keyboard open after a `search` action.
  final bool maintainFocusOnSearch;

  /// Allow long-pressing backspace to continuously delete.
  final bool enableLongPressDelete;

  /// Allow holding a character key to repeat it.
  final bool enableKeyRepeat;

  /// Auto-engage temporary shift for the first letter of an empty field /
  /// after sentence punctuation. Disabled for password layouts.
  final bool autoShiftFirstLetter;

  /// On desktop, also accept input from a physical keyboard while focused.
  final bool hardwareKeyboardFallback;

  /// Add an action/enter key (a "Done"-style bar) to numeric pads
  /// (number/decimal/pin/phone). The key performs the field's
  /// [TextInputAction] — submit, move focus, etc.
  final bool numericActionKey;

  /// When a field gains focus, scroll it into view above the keyboard (via
  /// the nearest [Scrollable]) so it isn't hidden behind the keyboard.
  final bool scrollFocusedIntoView;

  /// Delay before long-press delete begins repeating.
  final Duration longPressDeleteDelay;

  /// Delay before a held character key starts repeating.
  final Duration keyRepeatDelay;

  /// Interval between repeats once repeating has started.
  final Duration keyRepeatInterval;

  /// Show/hide animation duration.
  final Duration animationDuration;

  /// Show/hide animation curve.
  final Curve animationCurve;

  VKeyboardConfig copyWith({
    bool? hideOnDone,
    bool? submitOnDone,
    bool? moveFocusOnNext,
    bool? moveFocusOnPrevious,
    bool? closeOnOutsideTap,
    bool? maintainFocusOnSearch,
    bool? enableLongPressDelete,
    bool? enableKeyRepeat,
    bool? autoShiftFirstLetter,
    bool? hardwareKeyboardFallback,
    bool? numericActionKey,
    bool? scrollFocusedIntoView,
    Duration? longPressDeleteDelay,
    Duration? keyRepeatDelay,
    Duration? keyRepeatInterval,
    Duration? animationDuration,
    Curve? animationCurve,
    bool? enableClipboardHistory,
    int? maxClipboardHistoryItems,
    bool? syncSystemClipboard,
    bool? showHideKeyboardButton,
    List<String>? enabledLayouts,
    String? defaultLayout,
    bool? showGlobeKey,
    bool? persistLayoutSelection,
    bool? openPickerOnTap,
  }) {
    return VKeyboardConfig(
      hideOnDone: hideOnDone ?? this.hideOnDone,
      submitOnDone: submitOnDone ?? this.submitOnDone,
      moveFocusOnNext: moveFocusOnNext ?? this.moveFocusOnNext,
      moveFocusOnPrevious: moveFocusOnPrevious ?? this.moveFocusOnPrevious,
      closeOnOutsideTap: closeOnOutsideTap ?? this.closeOnOutsideTap,
      maintainFocusOnSearch:
          maintainFocusOnSearch ?? this.maintainFocusOnSearch,
      enableLongPressDelete:
          enableLongPressDelete ?? this.enableLongPressDelete,
      enableKeyRepeat: enableKeyRepeat ?? this.enableKeyRepeat,
      autoShiftFirstLetter: autoShiftFirstLetter ?? this.autoShiftFirstLetter,
      hardwareKeyboardFallback:
          hardwareKeyboardFallback ?? this.hardwareKeyboardFallback,
      numericActionKey: numericActionKey ?? this.numericActionKey,
      scrollFocusedIntoView:
          scrollFocusedIntoView ?? this.scrollFocusedIntoView,
      longPressDeleteDelay: longPressDeleteDelay ?? this.longPressDeleteDelay,
      keyRepeatDelay: keyRepeatDelay ?? this.keyRepeatDelay,
      keyRepeatInterval: keyRepeatInterval ?? this.keyRepeatInterval,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      enableClipboardHistory:
          enableClipboardHistory ?? this.enableClipboardHistory,
      maxClipboardHistoryItems:
          maxClipboardHistoryItems ?? this.maxClipboardHistoryItems,
      syncSystemClipboard: syncSystemClipboard ?? this.syncSystemClipboard,
      showHideKeyboardButton:
          showHideKeyboardButton ?? this.showHideKeyboardButton,
      enabledLayouts: enabledLayouts ?? this.enabledLayouts,
      defaultLayout: defaultLayout ?? this.defaultLayout,
      showGlobeKey: showGlobeKey ?? this.showGlobeKey,
      persistLayoutSelection:
          persistLayoutSelection ?? this.persistLayoutSelection,
      openPickerOnTap: openPickerOnTap ?? this.openPickerOnTap,
    );
  }
}
