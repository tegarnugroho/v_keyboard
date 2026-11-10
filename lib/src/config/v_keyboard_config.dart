import 'package:flutter/widgets.dart';

import '../models/desktop_key_model.dart';
import '../models/v_keyboard_locale.dart';

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
    this.showClipboardButton = true,
    List<String>? enabledLayouts,
    this.enabledLocales,
    String? defaultLayout,
    this.defaultLocale,
    this.showGlobeKey = false,
    this.persistLayoutSelection = true,
    this.openPickerOnTap = true,
    this.enableImeCandidates = true,
    this.maxImeCandidates = 8,
    this.candidateBarHeight = 38.0,
    this.desktopFormFactor,
    this.keyboardHeight,
    this.keyboardHeightFactor,
    this.minKeyboardHeight,
    this.maxKeyboardHeight,
    this.keyHeight,
    this.maxKeyboardWidth,
    this.numericPadMaxWidth,
  })  : _enabledLayouts = enabledLayouts,
        _defaultLayout = defaultLayout;

  final List<String>? _enabledLayouts;
  final String? _defaultLayout;

  /// Type-safe enum list of enabled built-in locales (e.g. `[VKeyboardLocale.enUS, VKeyboardLocale.deDE]`).
  ///
  /// When provided, this automatically populates [enabledLayouts] with their corresponding layout IDs.
  final List<VKeyboardLocale>? enabledLocales;

  /// Type-safe initial built-in locale.
  final VKeyboardLocale? defaultLocale;

  /// Enabled layout IDs for switching via space bar hold or the globe key.
  ///
  /// Defaults to `['en_US']`. If [enabledLocales] is specified, it returns the IDs
  /// of those locales.
  List<String> get enabledLayouts {
    if (enabledLocales != null && enabledLocales!.isNotEmpty) {
      return enabledLocales!.map((l) => l.id).toList();
    }
    return _enabledLayouts ?? const ['en_US'];
  }

  /// The initial layout to use before any selection is made.
  ///
  /// Defaults to [defaultLocale]'s ID, [defaultLayout], the first layout in [enabledLayouts], or `'en_US'`.
  String? get defaultLayout => defaultLocale?.id ?? _defaultLayout;

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

  /// Whether IME candidate suggestion bars are displayed for CJK layouts.
  final bool enableImeCandidates;

  /// Maximum number of candidate suggestions displayed in the candidate bar.
  final int maxImeCandidates;

  /// The height of the candidate bar strip displayed above the keyboard.
  final double candidateBarHeight;

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

  /// Whether to show a clipboard button on the far right of the bottom bar
  /// aligned with the dismiss button on mobile layouts.
  final bool showClipboardButton;

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
  /// Form factor for `VKeyboardType.desktop` fields. When set, the scope
  /// renders [DesktopFullKeyboard] with this preset (e.g.
  /// [KeyboardLayoutType.layout60]); when null, the built-in OSK-style
  /// desktop layout is used.
  final KeyboardLayoutType? desktopFormFactor;

  /// Optional explicit fixed height (in logical pixels) for the keyboard content
  /// area (excluding bottom utility bar or safe-area inset).
  ///
  /// When provided, this overrides dynamic viewport fraction and row-height
  /// calculations across all form factors.
  final double? keyboardHeight;

  /// Optional fraction of the total viewport height (e.g. `0.40` for 40% of screen height)
  /// that the keyboard content area should occupy.
  ///
  /// Particularly useful on large desktop/kiosk/POS monitors (such as 24", 27", 32" screens)
  /// where the default desktop height may otherwise feel too short.
  final double? keyboardHeightFactor;

  /// Optional minimum bound on keyboard content height in logical pixels.
  final double? minKeyboardHeight;

  /// Optional maximum bound on keyboard content height in logical pixels.
  final double? maxKeyboardHeight;

  /// Optional preferred height for key rows in logical pixels.
  final double? keyHeight;

  /// Optional upper bound on keyboard content width in logical pixels. On viewports
  /// wider than this value, the keyboard is horizontally centered.
  final double? maxKeyboardWidth;

  /// Optional upper bound on numeric/compact keyboards (`number`, `pin`, `decimal`, `phone`).
  ///
  /// Defaults to `480.0` on wide desktop/POS screens (>= 1200px width), `420.0` on tablets,
  /// and `360.0` on phones.
  final double? numericPadMaxWidth;

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
    bool? showClipboardButton,
    List<String>? enabledLayouts,
    List<VKeyboardLocale>? enabledLocales,
    String? defaultLayout,
    VKeyboardLocale? defaultLocale,
    bool? showGlobeKey,
    bool? persistLayoutSelection,
    bool? openPickerOnTap,
    bool? enableImeCandidates,
    int? maxImeCandidates,
    double? candidateBarHeight,
    KeyboardLayoutType? desktopFormFactor,
    double? keyboardHeight,
    double? keyboardHeightFactor,
    double? minKeyboardHeight,
    double? maxKeyboardHeight,
    double? keyHeight,
    double? maxKeyboardWidth,
    double? numericPadMaxWidth,
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
      showClipboardButton: showClipboardButton ?? this.showClipboardButton,
      enabledLayouts: enabledLayouts ?? _enabledLayouts,
      enabledLocales: enabledLocales ?? this.enabledLocales,
      defaultLayout: defaultLayout ?? _defaultLayout,
      defaultLocale: defaultLocale ?? this.defaultLocale,
      showGlobeKey: showGlobeKey ?? this.showGlobeKey,
      persistLayoutSelection:
          persistLayoutSelection ?? this.persistLayoutSelection,
      openPickerOnTap: openPickerOnTap ?? this.openPickerOnTap,
      enableImeCandidates: enableImeCandidates ?? this.enableImeCandidates,
      maxImeCandidates: maxImeCandidates ?? this.maxImeCandidates,
      candidateBarHeight: candidateBarHeight ?? this.candidateBarHeight,
      desktopFormFactor: desktopFormFactor ?? this.desktopFormFactor,
      keyboardHeight: keyboardHeight ?? this.keyboardHeight,
      keyboardHeightFactor: keyboardHeightFactor ?? this.keyboardHeightFactor,
      minKeyboardHeight: minKeyboardHeight ?? this.minKeyboardHeight,
      maxKeyboardHeight: maxKeyboardHeight ?? this.maxKeyboardHeight,
      keyHeight: keyHeight ?? this.keyHeight,
      maxKeyboardWidth: maxKeyboardWidth ?? this.maxKeyboardWidth,
      numericPadMaxWidth: numericPadMaxWidth ?? this.numericPadMaxWidth,
    );
  }
}
