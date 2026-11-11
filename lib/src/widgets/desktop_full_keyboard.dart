import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide ModifierKey;

import '../controller/v_keyboard_controller.dart';
import '../layouts/v_keyboard_layouts.dart';
import '../models/desktop_key_model.dart';
import '../models/key_data.dart';
import '../models/key_intents.dart';
import '../scope/v_keyboard_scope.dart';
import '../theme/v_keyboard_theme.dart';
import 'candidate_bar.dart';
import 'clipboard_history_panel.dart';
import 'layout_picker_dialog.dart';
import 'virtual_key_button.dart';

/// A full-featured, edge-to-edge responsive Desktop On-Screen Keyboard widget
/// supporting multiple hardware form factors (`60%`, `65%`, `75%`, `87% TKL`,
/// `98%`, and `100% Full-Size`).
///
/// Keys use proportional `Expanded(flex: N)` sizing so any preset expands smoothly
/// across full monitor widths when [isFullWidth] is true, or can be capped cleanly
/// on ultra-wide screens via [maxWidth] / [isFullWidth].
class DesktopFullKeyboard extends StatefulWidget {
  const DesktopFullKeyboard({
    super.key,
    this.layoutType = KeyboardLayoutType.layout100,
    this.platform = DesktopKeyboardPlatform.windows,
    this.layoutId,
    this.availableLayouts,
    this.showPlatformToggle = true,
    this.showLocaleSelector = true,
    this.showCandidateBar = true,
    this.onPlatformChanged,
    this.onLayoutChanged,
    this.themeData,
    this.showNumpad = true,
    this.showFunctionRow = true,
    this.showHeader = true,
    this.isFullWidth = true,
    this.maxWidth,
    this.padding,
    this.maxKeyboardHeightRatio = 0.38,
    this.initialCapsLock = false,
    this.initialNumLock = true,
    this.onKeyPressed,
    this.onSpecialKeyPressed,
    this.onShortcutTriggered,
    this.onDismiss,
    this.showHideKeyboardButton,
    this.hideIcon,
    this.showGlobeKey,
    this.globeIcon,
    this.showClipboardButton,
    this.clipboardIcon,
    this.onClipboardTap,
    this.bottomSafeArea = 0.0,
    this.height,
    this.keyHeight,
    this.controller,
  });

  /// Physical layout form-factor preset (`layout60`, `layout65`, `layout75`,
  /// `layout87TKL`, `layout98`, `layout100`). Defaults to [KeyboardLayoutType.layout100].
  final KeyboardLayoutType layoutType;

  /// Hardware OS layout convention (`windows` or `macos`). Defaults to
  /// [DesktopKeyboardPlatform.windows]. Users can also switch live via the
  /// header toggle when [showPlatformToggle] is true.
  final DesktopKeyboardPlatform platform;

  /// Whether to render a compact `[Win | Mac]` OS toggle chip inside the
  /// status header bar when [showHeader] is true. Defaults to `true`.
  final bool showPlatformToggle;

  /// Invoked when the user switches the platform preset via the header toggle.
  final ValueChanged<DesktopKeyboardPlatform>? onPlatformChanged;

  /// Active language/keyboard layout ID (e.g. `'en_US'`, `'zh_CN'`, `'ja_JP'`,
  /// `'ko_KR'`, `'ru_RU'`, `'th_TH'`, `'el_GR'`, `'de_DE'`).
  ///
  /// When omitted, tracks the attached [VKeyboardController.currentLayoutId] or
  /// defaults to `'en_US'`. Users can also switch languages live via the
  /// taskbar-style `🌐` locale pill in the header or by long-pressing Spacebar.
  final String? layoutId;

  /// Optional list of layout IDs shown in the desktop locale selector menu.
  ///
  /// When omitted, uses the attached [VKeyboardController]'s `enabledLayouts`
  /// when more than one layout is configured, or all registered built-in
  /// layouts in [VKeyboardLayouts.all].
  final List<String>? availableLayouts;

  /// Whether to render the taskbar/menubar-style `🌐 <Language> ▾` switcher
  /// chip inside the status header bar and enable Spacebar long-press locale
  /// switching. Defaults to `true`.
  final bool showLocaleSelector;

  /// Whether to automatically show the IME [CandidateBar] strip above the key
  /// grid during CJK composition (`zh_CN` Pinyin, `zh_TW` Zhuyin, `ja_JP` Kana)
  /// when bound to a [VKeyboardController]. Defaults to `true`.
  final bool showCandidateBar;

  /// Invoked whenever the active desktop keyboard layout changes.
  final ValueChanged<String>? onLayoutChanged;

  /// Visual theme data for background, keycaps, borders, and active LEDs.
  /// Defaults to [DesktopKeyboardThemeData.dark()].
  final DesktopKeyboardThemeData? themeData;

  /// Initial visibility of the Numpad on Numpad-capable presets (`layout98`,
  /// `layout100`). Can also be toggled live via the header button.
  final bool showNumpad;

  /// Whether to show the top Function row on presets that include it (`layout75`,
  /// `layout87TKL`, `layout98`, `layout100`). Compact `layout60`/`layout65` always
  /// omit the F-row in favor of the `Fn` layer.
  final bool showFunctionRow;

  /// Whether to render the OSK status header bar (active layout label,
  /// `Hide Numpad` toggle button, and `FN` / `CAPS` / `NUM` LED status indicators).
  final bool showHeader;

  /// When `true` (default), the keyboard spans edge-to-edge across the entire
  /// available width (`width: double.infinity`), even in compact `60%`/`65%` modes.
  /// Set `false` to apply natural aspect-proportioned width limits centered on
  /// wide desktop monitors.
  final bool isFullWidth;

  /// Optional upper bound on keyboard grid width (in logical pixels) to prevent
  /// compact presets like `60%` or `65%` from stretching overly wide on ultrawide monitors.
  final double? maxWidth;

  /// Optional custom outer padding around the keyboard clusters. When omitted,
  /// dynamic viewport-proportional horizontal padding is calculated automatically.
  final EdgeInsetsGeometry? padding;

  /// Maximum fraction of the total viewport height this keyboard may occupy
  /// (e.g. `0.38` = max 38% of screen height).
  final double maxKeyboardHeightRatio;

  /// Initial active state for Caps Lock.
  final bool initialCapsLock;

  /// Initial active state for Num Lock. Defaults to `true`.
  final bool initialNumLock;

  /// Invoked when a printable character (or space `' '`) is typed without
  /// a command shortcut or `Fn` override active.
  final ValueChanged<String>? onKeyPressed;

  /// Invoked when a special, modifier, lock, function, navigation, or `Fn`-layer key is pressed.
  final ValueChanged<VirtualKeyAction>? onSpecialKeyPressed;

  /// Invoked when a modifier shortcut combo is triggered (e.g. `'Ctrl+A'`,
  /// `'Ctrl+Shift+Z'`, `'Alt+F4'`).
  final ValueChanged<String>? onShortcutTriggered;

  /// Optional callback invoked when the bottom-left dismiss arrow button is
  /// tapped. When [showHideKeyboardButton] is null, providing [onDismiss]
  /// automatically shows the close arrow in the bottom bar; when null, tapping
  /// the arrow falls back to `controller.hide()`.
  final VoidCallback? onDismiss;

  /// Whether to render the non-desktop-style bottom utility bar close arrow
  /// (`Icons.keyboard_arrow_down_rounded`) on the far left below the keys.
  ///
  /// When null, defaults to `true` if [onDismiss] is provided or an attached
  /// [VKeyboardController] has `config.showHideKeyboardButton` enabled.
  final bool? showHideKeyboardButton;

  /// Optional custom icon for the bottom-left dismiss button. Defaults to
  /// [Icons.keyboard_arrow_down_rounded].
  final IconData? hideIcon;

  /// Whether to show the globe language switcher button next to the close arrow
  /// in the bottom utility bar.
  ///
  /// When null, defaults to `true` only when [showHeader] is `false` and the
  /// attached [VKeyboardController] enables `config.showGlobeKey` with 2+ layouts.
  final bool? showGlobeKey;

  /// Optional custom icon for the bottom-bar globe button. Defaults to
  /// [Icons.language].
  final IconData? globeIcon;

  /// Whether to show the clipboard history button on the far right of the
  /// bottom utility bar (matching mobile [KeyboardView]).
  ///
  /// When null, defaults to `true` when an attached [VKeyboardController] has
  /// `config.enableClipboardHistory` and `config.showClipboardButton` enabled.
  final bool? showClipboardButton;

  /// Optional custom icon for the bottom-right clipboard button. Defaults to
  /// [Icons.content_paste_rounded].
  final IconData? clipboardIcon;

  /// Optional callback invoked when the bottom-right clipboard button is tapped.
  /// Defaults to `controller.openClipboardHistory()`.
  final VoidCallback? onClipboardTap;

  /// Bottom safe-area / bar height (matching [KeyboardView.bottomSafeArea]).
  /// When any bottom utility button is visible, the bar is at least `36.0` px tall.
  final double bottomSafeArea;

  /// Optional explicit fixed height for the keyboard content. When provided,
  /// overrides dynamic ratio and row-height calculations.
  final double? height;

  /// Optional preferred height for key rows in logical pixels.
  final double? keyHeight;

  /// Optional [VKeyboardController] for direct integration with [VTextField]
  /// sessions and hardware shortcut dispatch.
  final VKeyboardController? controller;

  @override
  State<DesktopFullKeyboard> createState() => _DesktopFullKeyboardState();
}

class _DesktopFullKeyboardState extends State<DesktopFullKeyboard> {
  VKeyboardController? _boundController;
  late bool _showNumpad = widget.showNumpad;
  late DesktopKeyboardPlatform _platform = widget.platform;
  late String _layoutId =
      widget.layoutId ?? widget.controller?.currentLayoutId ?? 'en_US';
  bool _isShiftActive = false;
  late bool _isCapsLockActive = widget.initialCapsLock;
  late bool _isNumLockActive = widget.initialNumLock;
  bool _isCtrlActive = false;
  bool _isAltActive = false;
  bool _isAltGrActive = false;
  bool _isWinActive = false;
  bool _isFnActive = false;
  bool _isScrollLockActive = false;

  @override
  void initState() {
    super.initState();
    _bindController(widget.controller);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final inherited = VKeyboardScope.maybeOf(context)?.controller;
    _bindController(widget.controller ?? inherited);
  }

  @override
  void didUpdateWidget(covariant DesktopFullKeyboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showNumpad != oldWidget.showNumpad) {
      _showNumpad = widget.showNumpad;
    }
    if (widget.platform != oldWidget.platform) {
      _platform = widget.platform;
    }
    if (widget.controller != oldWidget.controller) {
      final inherited = VKeyboardScope.maybeOf(context)?.controller;
      _bindController(widget.controller ?? inherited);
    }
    if (widget.layoutId != null && widget.layoutId != oldWidget.layoutId) {
      _layoutId = widget.layoutId!;
      if (_boundController != null &&
          _boundController!.currentLayoutId != widget.layoutId) {
        _boundController!.setLayout(widget.layoutId!);
      }
    }
  }

  @override
  void dispose() {
    _boundController?.removeListener(_syncFromController);
    super.dispose();
  }

  void _bindController(VKeyboardController? next) {
    if (identical(_boundController, next)) return;
    _boundController?.removeListener(_syncFromController);
    _boundController = next;
    if (next != null) {
      next.addListener(_syncFromController);
      _applyControllerState(next);
      if (widget.layoutId != null && next.currentLayoutId != widget.layoutId) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _boundController == next) {
            next.setLayout(widget.layoutId!);
          }
        });
      }
    }
  }

  void _applyControllerState(VKeyboardController c) {
    _isShiftActive = c.modifiers.shift;
    _isCapsLockActive = c.modifiers.capsLock;
    _isScrollLockActive = c.modifiers.scrollLock;
    _isCtrlActive = c.modifiers.control;
    _isAltActive = c.modifiers.alt;
    _isAltGrActive = c.modifiers.altGr;
    _isWinActive = c.modifiers.meta;
    if (widget.layoutId == null) {
      _layoutId = c.currentLayoutId;
    }
  }

  void _syncFromController() {
    final c = _boundController;
    if (c == null || !mounted) return;
    final prevLayout = _layoutId;
    final nextLayout = c.currentLayoutId;
    setState(() {
      _isShiftActive = c.modifiers.shift;
      _isCapsLockActive = c.modifiers.capsLock;
      _isScrollLockActive = c.modifiers.scrollLock;
      _isCtrlActive = c.modifiers.control;
      _isAltActive = c.modifiers.alt;
      _isAltGrActive = c.modifiers.altGr;
      _isWinActive = c.modifiers.meta;
      _layoutId = nextLayout;
    });
    if (prevLayout != nextLayout) {
      widget.onLayoutChanged?.call(nextLayout);
    }
  }

  List<String> get _resolvedAvailableLayouts {
    if (widget.availableLayouts != null &&
        widget.availableLayouts!.isNotEmpty) {
      return widget.availableLayouts!;
    }
    final ctrl = _boundController;
    if (ctrl != null && ctrl.config.enabledLayouts.length > 1) {
      return ctrl.config.enabledLayouts;
    }
    return VKeyboardLayouts.all.map((m) => m.id).toList(growable: false);
  }

  void _selectLocale(String id) {
    final ctrl = _boundController;
    if (ctrl != null) {
      if (ctrl.currentLayoutId != id) {
        ctrl.setLayout(id);
      } else if (_layoutId != id) {
        setState(() => _layoutId = id);
        widget.onLayoutChanged?.call(id);
      }
      return;
    }
    if (_layoutId == id) return;
    setState(() => _layoutId = id);
    widget.onLayoutChanged?.call(id);
  }

  String? _desktopImeHint(String id) {
    return switch (id) {
      'zh_CN' => 'Pinyin IME',
      'zh_TW' => 'Zhuyin IME',
      'ja_JP' => 'Kana IME',
      'ko_KR' => '2-Bulsik Hangul',
      'vi_VN' => 'Telex',
      'th_TH' => 'Kedmanee',
      'ru_RU' => 'JCUKEN',
      'el_GR' => 'Greek',
      'de_DE' => 'QWERTZ',
      'fr_FR' => 'AZERTY',
      _ => null,
    };
  }

  VKeyboardTheme _toVKeyboardTheme(DesktopKeyboardThemeData t) {
    final isDark = t.backgroundColor.computeLuminance() < 0.5;
    return VKeyboardTheme(
      backgroundColor: t.backgroundColor,
      keyColor: t.keyColor,
      pressedKeyColor: t.pressedKeyColor,
      specialKeyColor: t.specialKeyColor,
      disabledKeyColor: t.keyColor.withValues(alpha: 0.45),
      textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: t.textColor,
      ),
      iconColor: t.textColor,
      subLabelStyle: TextStyle(
        fontSize: 10,
        color: t.secondaryTextColor,
      ),
      accentColor: t.ledActiveColor,
      activeKeyColor: isDark ? t.activeKeyColor : t.accentKeyColor,
      activeForegroundColor: Colors.white,
    );
  }

  Future<void> _openLocalePicker(DesktopKeyboardThemeData theme) async {
    final ctrl = _boundController;
    final layouts = _resolvedAvailableLayouts;
    if (layouts.isEmpty) return;

    if (widget.availableLayouts == null &&
        ctrl != null &&
        ctrl.config.enabledLayouts.length > 1 &&
        VKeyboardScope.maybeOf(context)?.controller == ctrl) {
      await showVKeyboardLayoutPicker(
        context,
        controller: ctrl,
        theme: _toVKeyboardTheme(theme),
      );
      return;
    }

    await _showDesktopLocaleDialog(context, theme, layouts);
  }

  Future<void> _showDesktopLocaleDialog(
    BuildContext context,
    DesktopKeyboardThemeData theme,
    List<String> layouts,
  ) async {
    final tapGroup = VKeyboardScope.maybeOf(context)?.tapGroup;
    final selected = await showDialog<String>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) {
        final screenW = MediaQuery.of(ctx).size.width;
        final isTwoColumn = screenW >= 640;

        Widget buildLocaleTile(String id) {
          final isSelected = id == _layoutId;
          final name = VKeyboardLayouts.getDisplayName(id);
          final code = VKeyboardLayouts.getShortLabel(id);
          final hint = _desktopImeHint(id);

          return InkWell(
            key: ValueKey('dk_locale_opt_$id'),
            onTap: () => Navigator.of(ctx).pop(id),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? theme.activeKeyColor : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(
                        color: theme.activeBorderColor.withValues(alpha: 0.7),
                      )
                    : Border.all(
                        color: theme.keyBorderColor.withValues(alpha: 0.45),
                      ),
              ),
              child: Row(
                children: [
                  Container(
                    constraints: const BoxConstraints(minWidth: 34),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.specialKeyColor,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: theme.keyBorderColor),
                    ),
                    child: Text(
                      code,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: theme.headerTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? theme.activeTextColor
                            : theme.textColor,
                      ),
                    ),
                  ),
                  if (hint != null) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.ledActiveColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        hint,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: theme.ledActiveColor,
                        ),
                      ),
                    ),
                  ],
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: theme.ledActiveColor,
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        Widget dialog = Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTwoColumn ? 620 : 400,
              maxHeight: 520,
            ),
            child: Material(
              color: theme.backgroundColor,
              elevation: 16,
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.keyBorderColor, width: 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.language_rounded,
                            size: 18,
                            color: theme.ledActiveColor,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Desktop Input Language',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: theme.headerTextColor,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            icon: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: theme.headerSubtitleColor,
                            ),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 28,
                              minHeight: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: theme.keyBorderColor,
                    ),
                    Flexible(
                      child: isTwoColumn
                          ? GridView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(10),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisExtent: 44,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 6,
                              ),
                              itemCount: layouts.length,
                              itemBuilder: (_, index) =>
                                  buildLocaleTile(layouts[index]),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(8),
                              itemCount: layouts.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 4),
                              itemBuilder: (_, index) =>
                                  buildLocaleTile(layouts[index]),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        if (tapGroup != null) {
          dialog = TapRegion(groupId: tapGroup, child: dialog);
        }
        return dialog;
      },
    );

    if (selected != null && mounted) {
      _selectLocale(selected);
    }
  }

  String _resolveSpaceLabel() {
    final banner = _boundController?.spaceBarBanner;
    if (banner != null && banner.isNotEmpty) return banner;
    if (_layoutId != 'en_US') {
      return VKeyboardLayouts.getDisplayName(_layoutId);
    }
    return _platform == DesktopKeyboardPlatform.macos ? 'space' : 'SPACEBAR';
  }

  bool get _hasShortcutModifier =>
      _isCtrlActive || _isAltActive || _isWinActive;

  bool _isKeyEngaged(KeyModel model) {
    return switch (model.action) {
      VirtualKeyAction.leftShift || VirtualKeyAction.rightShift => _isShiftActive,
      VirtualKeyAction.capsLock => _isCapsLockActive,
      VirtualKeyAction.numLock => _isNumLockActive,
      VirtualKeyAction.scrollLock => _isScrollLockActive,
      VirtualKeyAction.leftCtrl || VirtualKeyAction.rightCtrl => _isCtrlActive,
      VirtualKeyAction.leftAlt || VirtualKeyAction.rightOption => _isAltActive,
      VirtualKeyAction.altGr => _isAltGrActive,
      VirtualKeyAction.winSuper ||
      VirtualKeyAction.leftCommand ||
      VirtualKeyAction.rightCommand =>
        _isWinActive,
      VirtualKeyAction.fn => _isFnActive,
      _ => false,
    };
  }

  void _handleKeyTap(KeyModel key) {
    final action = key.action;
    final controller = _boundController;

    // 1. Handle Modifier & Lock State Keys.
    if (key.type == KeyType.modifier || key.type == KeyType.lock) {
      _toggleStateKey(key);
      if (action != null) {
        widget.onSpecialKeyPressed?.call(action);
      }
      return;
    }

    // 2. Active Fn-Layer Override (F1-F12, Esc, Del, Arrows, Home/End/PgUp/PgDn on 60%/65%).
    if (_isFnActive && key.hasFnMapping) {
      if (_hasShortcutModifier) {
        final token = key.fnShortcutKey ?? key.fnLabel ?? key.label;
        final combo = _buildShortcutCombo(token);
        widget.onShortcutTriggered?.call(combo);
        final fnKeyData = key.toFnKeyData();
        if (controller != null && fnKeyData != null) {
          controller.handleKey(fnKeyData);
        }
        _clearMomentaryModifiers();
        return;
      }

      if (key.fnAction != null) {
        widget.onSpecialKeyPressed?.call(key.fnAction!);
      }
      final fnKeyData = key.toFnKeyData();
      if (controller != null && fnKeyData != null) {
        controller.handleKey(fnKeyData);
      }
      _clearMomentaryModifiers();
      return;
    }

    // 3. Numpad digit / decimal when Num Lock is OFF behaves as navigation/edit.
    if (key.isNumpadDigit && !_isNumLockActive) {
      final secAction = key.secondaryAction;
      if (secAction != null) {
        widget.onSpecialKeyPressed?.call(secAction);
      }
      if (controller != null) {
        if (key.secondaryNavIntent != null) {
          controller.handleKey(
            KeyData.nav(key.secondaryNavIntent!, label: key.secondaryLabel),
          );
        } else if (secAction == VirtualKeyAction.insert) {
          controller.handleKey(
            KeyData.function('Ins', LogicalKeyboardKey.insert),
          );
        } else if (secAction == VirtualKeyAction.delete) {
          controller.handleKey(
            KeyData.function('Del', LogicalKeyboardKey.delete),
          );
        }
      }
      _clearMomentaryModifiers();
      return;
    }

    // 4. Check for shortcut combo (Ctrl / Alt / Win / Cmd held + target key).
    if (_hasShortcutModifier) {
      final shortcutToken =
          key.shortcutKey ?? key.value?.toUpperCase() ?? key.label;
      final combo = _buildShortcutCombo(shortcutToken);
      widget.onShortcutTriggered?.call(combo);

      if (controller != null) {
        final isMacPureCmd = _platform == DesktopKeyboardPlatform.macos &&
            _isWinActive &&
            !_isCtrlActive &&
            !_isAltActive &&
            !_isShiftActive;
        final lowerChar = key.value?.toLowerCase();
        if (isMacPureCmd &&
            (lowerChar == 'a' ||
                lowerChar == 'c' ||
                lowerChar == 'x' ||
                lowerChar == 'v')) {
          final intent = switch (lowerChar) {
            'a' => ClipboardIntent.selectAll,
            'c' => ClipboardIntent.copy,
            'x' => ClipboardIntent.cut,
            _ => ClipboardIntent.paste,
          };
          controller.handleKey(KeyData.clipboard(intent));
        } else {
          final keyData = key.toKeyData();
          if (keyData != null) {
            controller.handleKey(keyData);
          }
        }
      }
      _clearMomentaryModifiers();
      return;
    }

    // 5. Spacebar: invokes onKeyPressed(' ').
    if (key.type == KeyType.space) {
      widget.onKeyPressed?.call(' ');
      if (controller != null) {
        controller.handleKey(KeyData.space());
      }
      _clearMomentaryModifiers();
      return;
    }

    // 6. Printable characters (Alphanumeric, Dual-Legend symbols, Numpad active digits/ops).
    if (key.type == KeyType.character) {
      String? altGrOutput;
      if (_isAltGrActive &&
          !_isCtrlActive &&
          !_isWinActive &&
          key.value != null) {
        altGrOutput = VKeyboardLayouts.getAltGr(_layoutId)[key.value];
      }
      final output = altGrOutput ??
          key.resolveOutput(
            shifted: _isShiftActive,
            capsLock: _isCapsLockActive,
          );
      if (output != null) {
        widget.onKeyPressed?.call(output);
        if (controller != null) {
          final keyData = key.toKeyData();
          if (keyData != null && controller.session != null) {
            controller.handleKey(keyData);
          } else {
            controller.insertText(output);
          }
        }
      }
      _clearMomentaryModifiers();
      return;
    }

    // 7. Special / Action / Function / Navigation keys (Enter, Backspace, Tab, Del, Arrows, etc.).
    if (action != null) {
      widget.onSpecialKeyPressed?.call(action);
    }
    if (controller != null) {
      final keyData = key.toKeyData();
      if (keyData != null) {
        controller.handleKey(keyData);
      }
    }
    _clearMomentaryModifiers();
  }

  void _toggleStateKey(KeyModel key) {
    final controller = _boundController;
    if (key.action == VirtualKeyAction.numLock) {
      setState(() => _isNumLockActive = !_isNumLockActive);
      controller?.modifiers.toggleLock(LockKey.numLock);
      return;
    }
    if (key.action == VirtualKeyAction.fn) {
      setState(() => _isFnActive = !_isFnActive);
      return;
    }
    if (controller != null) {
      if (key.modifierKey != null) {
        controller.modifiers.toggleModifier(key.modifierKey!);
        return;
      }
      if (key.lockKey != null) {
        controller.modifiers.toggleLock(key.lockKey!);
        return;
      }
    }

    setState(() {
      switch (key.action) {
        case VirtualKeyAction.leftShift:
        case VirtualKeyAction.rightShift:
          _isShiftActive = !_isShiftActive;
        case VirtualKeyAction.capsLock:
          _isCapsLockActive = !_isCapsLockActive;
        case VirtualKeyAction.scrollLock:
          _isScrollLockActive = !_isScrollLockActive;
        case VirtualKeyAction.leftCtrl:
        case VirtualKeyAction.rightCtrl:
          _isCtrlActive = !_isCtrlActive;
        case VirtualKeyAction.leftAlt:
        case VirtualKeyAction.rightOption:
          _isAltActive = !_isAltActive;
        case VirtualKeyAction.altGr:
          _isAltGrActive = !_isAltGrActive;
        case VirtualKeyAction.winSuper:
        case VirtualKeyAction.leftCommand:
        case VirtualKeyAction.rightCommand:
          _isWinActive = !_isWinActive;
        default:
          break;
      }
    });
  }

  void _clearMomentaryModifiers() {
    if (_boundController != null) {
      _boundController!.modifiers.clearMomentary();
    }
    if (_isShiftActive ||
        _isCtrlActive ||
        _isAltActive ||
        _isAltGrActive ||
        _isWinActive) {
      setState(() {
        _isShiftActive = false;
        _isCtrlActive = false;
        _isAltActive = false;
        _isAltGrActive = false;
        _isWinActive = false;
      });
    }
  }

  String _buildShortcutCombo(String target) {
    final isMac = _platform == DesktopKeyboardPlatform.macos;
    final parts = <String>[
      if (_isCtrlActive) 'Ctrl',
      if (_isWinActive) (isMac ? 'Cmd' : 'Win'),
      if (_isAltActive) (isMac ? 'Opt' : 'Alt'),
      if (_isShiftActive) 'Shift',
      target,
    ];
    return parts.join('+');
  }

  double _naturalMaxWidthFor(KeyboardLayoutType preset) {
    return switch (preset) {
      KeyboardLayoutType.layout60 => 860.0,
      KeyboardLayoutType.layout65 => 920.0,
      KeyboardLayoutType.layout75 => 960.0,
      KeyboardLayoutType.layout87TKL => 1140.0,
      KeyboardLayoutType.layout98 => 1220.0,
      KeyboardLayoutType.layout100 => 1380.0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.themeData ?? DesktopKeyboardThemeData.dark();
    final tapGroup = VKeyboardScope.maybeOf(context)?.tapGroup;

    Widget content = SizedBox(
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mq = MediaQuery.of(context);
          final screenH = mq.size.height > 0 ? mq.size.height : 900.0;
          final screenW = mq.size.width;
          final availW = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : mq.size.width;

          // Resolve effective width respecting isFullWidth & optional maxWidth.
          double effectiveGridWidth = availW;
          if (widget.maxWidth != null) {
            effectiveGridWidth = math.min(availW, widget.maxWidth!);
          } else if (!widget.isFullWidth) {
            effectiveGridWidth =
                math.min(availW, _naturalMaxWidthFor(widget.layoutType));
          }

          final canShowNav = availW >= 540;
          final canShowNumpad = availW >= 720;
          final effectiveShowNumpad = widget.layoutType.hasNumpad &&
              _showNumpad &&
              canShowNumpad;
          final includeFnRow =
              widget.layoutType.hasFunctionRow && widget.showFunctionRow;

          final totalUnits = switch (widget.layoutType) {
            KeyboardLayoutType.layout60 => 15,
            KeyboardLayoutType.layout65 => 16,
            KeyboardLayoutType.layout75 => 16,
            KeyboardLayoutType.layout87TKL => 15 + (canShowNav ? 3 : 0),
            KeyboardLayoutType.layout98 => 15 + (effectiveShowNumpad ? 4 : 0),
            KeyboardLayoutType.layout100 =>
              15 + (canShowNav ? 3 : 0) + (effectiveShowNumpad ? 4 : 0),
          };

          final rowCount = includeFnRow ? 6 : 5;
          final keyGap = (effectiveGridWidth * 0.004).clamp(2.5, 7.0);
          final keyMargin = keyGap / 2;
          final clusterGap = widget.layoutType == KeyboardLayoutType.layout98
              ? 0.0
              : (effectiveGridWidth * 0.011).clamp(6.0, 20.0);
          final hPadding = (effectiveGridWidth * 0.008).clamp(6.0, 16.0);

          final controller = _boundController;
          final hasImeCandidates = widget.showCandidateBar &&
              controller != null &&
              (controller.composingText.isNotEmpty ||
                  controller.candidates.isNotEmpty);
          const candidateBarHeight = 38.0;
          final candidateSectionHeight =
              hasImeCandidates ? candidateBarHeight + 6.0 : 0.0;
          final spaceLabel = _resolveSpaceLabel();

          final shouldShowHide = widget.showHideKeyboardButton ??
              (widget.onDismiss != null ||
                  (controller != null &&
                      controller.config.showHideKeyboardButton));
          final shouldShowBottomGlobe = widget.showGlobeKey ??
              (controller != null &&
                  !widget.showHeader &&
                  controller.config.showGlobeKey &&
                  controller.config.enabledLayouts.length >= 2);
          final shouldShowClipboard = widget.showClipboardButton ??
              (controller != null &&
                  controller.config.enableClipboardHistory &&
                  controller.config.showClipboardButton);
          final hasBottomBar =
              shouldShowHide || shouldShowBottomGlobe || shouldShowClipboard;
          final bottomBarHeight = hasBottomBar
              ? math.max(widget.bottomSafeArea, 36.0)
              : widget.bottomSafeArea;

          final isLandscape = screenW >= screenH;
          final isLargeDisplay = screenH >= 900;
          final defaultRatio =
              isLargeDisplay ? 0.44 : (isLandscape ? 0.38 : 0.32);
          final effectiveRatio = (widget.maxKeyboardHeightRatio != 0.38)
              ? widget.maxKeyboardHeightRatio
              : (controller?.config.keyboardHeightFactor ?? defaultRatio);
          final ratioCap = (screenH * effectiveRatio)
                  .clamp(180.0, screenH * (isLargeDisplay ? 0.65 : 0.44)) +
              (widget.bottomSafeArea > 0 ? widget.bottomSafeArea : 0.0);
          final maxAllowedH = constraints.hasBoundedHeight
              ? math.min(constraints.maxHeight, ratioCap)
              : ratioCap;

          final unitWidth = (effectiveGridWidth - hPadding * 2) / totalUnits;
          const heightUnits = 15;
          final idealUnitWidth =
              (effectiveGridWidth - hPadding * 2) / heightUnits;

          // On large desktop monitors (e.g. 24", 27", 32" screens), dynamically
          // allow row heights up to 92.0 so keys remain comfortable for touch.
          // On tablets (< 900p, e.g. 10.1" / 11" Android tablets & iPads), keep row
          // height compact (up to 48.0 in landscape) so the keyboard occupies ~32%-36%
          // of the screen instead of covering half the display.
          final maxRowCeiling = isLargeDisplay
              ? math.min(92.0, screenH * 0.085)
              : (isLandscape ? 48.0 : 54.0);
          final preferredKeyH =
              widget.keyHeight ?? controller?.config.keyHeight;
          final idealRowHeight = preferredKeyH ??
              (idealUnitWidth * 0.85).clamp(32.0, maxRowCeiling);
          final headerHeight =
              widget.showHeader ? (idealRowHeight * 0.72).clamp(26.0, 36.0) : 0.0;
          final vPadding = (idealRowHeight * 0.24).clamp(6.0, 14.0);
          final verticalOuterPadding =
              vPadding + (bottomBarHeight > 0 ? 0.0 : vPadding);
          final idealTotalH = headerHeight +
              (widget.showHeader ? 6.0 : 0.0) +
              candidateSectionHeight +
              rowCount * idealRowHeight +
              verticalOuterPadding +
              bottomBarHeight;

          final preferredTotalH =
              widget.height ?? controller?.config.keyboardHeight;
          final rawTotalH = preferredTotalH != null
              ? (preferredTotalH + bottomBarHeight)
              : idealTotalH;
          final totalHeight = math
              .min(rawTotalH, maxAllowedH)
              .clamp(math.min(180.0, maxAllowedH), maxAllowedH)
              .toDouble();

          final actualGridHeight = math.max(
            64.0,
            totalHeight -
                headerHeight -
                (widget.showHeader ? 6.0 : 0.0) -
                candidateSectionHeight -
                verticalOuterPadding -
                bottomBarHeight,
          );
          final actualRowHeight = actualGridHeight / rowCount;
          final baseFontSize = math
              .min(actualRowHeight * 0.36, unitWidth * 0.34)
              .clamp(9.5, 26.0);

          final resolvedPadding = widget.padding ??
              EdgeInsets.fromLTRB(
                hPadding,
                vPadding,
                hPadding,
                bottomBarHeight > 0 ? 0.0 : vPadding,
              );

          if (controller != null &&
              controller.currentPage == 'clipboard' &&
              widget.onClipboardTap == null) {
            final clipTotalH = math
                .max(totalHeight, math.min(280.0, maxAllowedH))
                .clamp(math.min(180.0, maxAllowedH), maxAllowedH)
                .toDouble();
            return ClipboardHistoryPanel(
              controller: controller,
              theme: _toVKeyboardTheme(theme),
              height: math.max(120.0, clipTotalH - bottomBarHeight),
              maxWidth: effectiveGridWidth,
              bottomSafeArea: bottomBarHeight,
            );
          }

          return Container(
            width: double.infinity,
            height: totalHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.backgroundColor,
              borderRadius: theme.containerBorderRadius,
              border: Border(
                top: BorderSide(color: theme.containerBorderColor, width: 1),
                bottom: theme.containerBorderRadius != BorderRadius.zero
                    ? BorderSide(color: theme.containerBorderColor, width: 1)
                    : BorderSide.none,
                left: theme.containerBorderRadius != BorderRadius.zero
                    ? BorderSide(color: theme.containerBorderColor, width: 1)
                    : BorderSide.none,
                right: theme.containerBorderRadius != BorderRadius.zero
                    ? BorderSide(color: theme.containerBorderColor, width: 1)
                    : BorderSide.none,
              ),
            ),
            child: SizedBox(
              width: effectiveGridWidth,
              child: Padding(
                padding: resolvedPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.showHeader) ...[
                      SizedBox(
                        height: headerHeight,
                        child: _buildHeaderBar(
                          theme: theme,
                          availW: effectiveGridWidth,
                          canShowNumpad: canShowNav && canShowNumpad,
                          effectiveShowNumpad: effectiveShowNumpad,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    if (hasImeCandidates) ...[
                      CandidateBar(
                        controller: controller,
                        theme: _toVKeyboardTheme(theme),
                        height: candidateBarHeight,
                      ),
                      const SizedBox(height: 6),
                    ],
                    Expanded(
                      child: _buildLayoutGrid(
                        theme: theme,
                        baseFontSize: baseFontSize,
                        keyMargin: keyMargin,
                        clusterGap: clusterGap,
                        canShowNav: canShowNav,
                        effectiveShowNumpad: effectiveShowNumpad,
                        includeFnRow: includeFnRow,
                        rowCount: rowCount,
                        spaceLabel: spaceLabel,
                      ),
                    ),
                    if (hasBottomBar)
                      _buildBottomUtilityBar(
                        context,
                        theme: theme,
                        height: bottomBarHeight,
                        showHide: shouldShowHide,
                        showGlobe: shouldShowBottomGlobe,
                        showClipboard: shouldShowClipboard,
                      )
                    else if (bottomBarHeight > 0)
                      SizedBox(height: bottomBarHeight),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    if (tapGroup != null) {
      content = TapRegion(groupId: tapGroup, child: content);
    }
    return content;
  }

  Widget _buildBottomUtilityBar(
    BuildContext context, {
    required DesktopKeyboardThemeData theme,
    required double height,
    required bool showHide,
    required bool showGlobe,
    required bool showClipboard,
  }) {
    final hasOverlay = Overlay.maybeOf(context) != null;
    final iconColor = theme.headerTextColor.withValues(alpha: 0.8);
    final dismissAction = widget.onDismiss ?? _boundController?.hide;
    final clipboardAction =
        widget.onClipboardTap ?? _boundController?.openClipboardHistory;

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showHide)
                Semantics(
                  button: true,
                  label: 'Close keyboard',
                  child: Tooltip(
                    message: hasOverlay ? 'Close keyboard' : '',
                    child: Material(
                      color: Colors.transparent,
                      child: InkResponse(
                        key: const ValueKey('dk_bottom_bar_close'),
                        onTap: dismissAction,
                        radius: 20,
                        highlightColor: theme.keyColor.withValues(alpha: 0.5),
                        splashColor:
                            theme.ledActiveColor.withValues(alpha: 0.2),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Icon(
                            widget.hideIcon ??
                                Icons.keyboard_arrow_down_rounded,
                            size: 24,
                            color: iconColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (showHide && showGlobe) const SizedBox(width: 4),
              if (showGlobe)
                Semantics(
                  button: true,
                  label: 'Switch keyboard language',
                  child: Tooltip(
                    message: hasOverlay ? 'Switch keyboard language' : '',
                    child: Material(
                      color: Colors.transparent,
                      child: InkResponse(
                        key: const ValueKey('dk_bottom_bar_globe'),
                        onTap: () => _openLocalePicker(theme),
                        onLongPress: () => _openLocalePicker(theme),
                        radius: 20,
                        highlightColor: theme.keyColor.withValues(alpha: 0.5),
                        splashColor:
                            theme.ledActiveColor.withValues(alpha: 0.2),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Icon(
                            widget.globeIcon ?? Icons.language,
                            size: 24,
                            color: iconColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (showClipboard)
            Semantics(
              button: true,
              label: 'Clipboard History',
              child: Tooltip(
                message: hasOverlay ? 'Clipboard History' : '',
                child: Material(
                  color: Colors.transparent,
                  child: InkResponse(
                    key: const ValueKey('dk_bottom_bar_clipboard'),
                    onTap: clipboardAction,
                    radius: 20,
                    highlightColor: theme.keyColor.withValues(alpha: 0.5),
                    splashColor: theme.ledActiveColor.withValues(alpha: 0.2),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Icon(
                        widget.clipboardIcon ?? Icons.content_paste_rounded,
                        size: 22,
                        color: iconColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---- Preset Builder Dispatch & Helpers ------------------------------------

  Widget _buildLayoutGrid({
    required DesktopKeyboardThemeData theme,
    required double baseFontSize,
    required double keyMargin,
    required double clusterGap,
    required bool canShowNav,
    required bool effectiveShowNumpad,
    required bool includeFnRow,
    required int rowCount,
    required String spaceLabel,
  }) {
    return switch (widget.layoutType) {
      KeyboardLayoutType.layout60 => _buildLayout60(
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
          spaceLabel: spaceLabel,
        ),
      KeyboardLayoutType.layout65 => _buildLayout65(
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
          spaceLabel: spaceLabel,
        ),
      KeyboardLayoutType.layout75 => _buildLayout75(
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
          includeFnRow: includeFnRow,
          spaceLabel: spaceLabel,
        ),
      KeyboardLayoutType.layout87TKL => _buildLayout87TKL(
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
          clusterGap: clusterGap,
          canShowNav: canShowNav,
          includeFnRow: includeFnRow,
          spaceLabel: spaceLabel,
        ),
      KeyboardLayoutType.layout98 => _buildLayout98(
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
          effectiveShowNumpad: effectiveShowNumpad,
          includeFnRow: includeFnRow,
          rowCount: rowCount,
          spaceLabel: spaceLabel,
        ),
      KeyboardLayoutType.layout100 => _buildLayout100(
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
          clusterGap: clusterGap,
          canShowNav: canShowNav,
          effectiveShowNumpad: effectiveShowNumpad,
          includeFnRow: includeFnRow,
          rowCount: rowCount,
          spaceLabel: spaceLabel,
        ),
    };
  }

  /// Renders **60% Compact**: 5 pure alphanumeric rows (15u) with `Fn` layer.
  Widget _buildLayout60({
    required DesktopKeyboardThemeData theme,
    required double baseFontSize,
    required double keyMargin,
    required String spaceLabel,
  }) {
    return _buildUnifiedRows(
      DesktopFullLayoutData.layout60Rows(
        platform: _platform,
        layoutId: _layoutId,
        spaceLabel: spaceLabel,
      ),
      theme: theme,
      baseFontSize: baseFontSize,
      keyMargin: keyMargin,
    );
  }

  /// Renders **65% Compact**: 5 rows (16u) with number row, integrated arrows, and right nav rail.
  Widget _buildLayout65({
    required DesktopKeyboardThemeData theme,
    required double baseFontSize,
    required double keyMargin,
    required String spaceLabel,
  }) {
    return _buildUnifiedRows(
      DesktopFullLayoutData.layout65Rows(
        platform: _platform,
        layoutId: _layoutId,
        spaceLabel: spaceLabel,
      ),
      theme: theme,
      baseFontSize: baseFontSize,
      keyMargin: keyMargin,
    );
  }

  /// Renders **75% Compact**: F-row on top, 1-column nav rail (`Del`, `Home`, `PgUp`, `PgDn`, `End`), tucked arrows.
  Widget _buildLayout75({
    required DesktopKeyboardThemeData theme,
    required double baseFontSize,
    required double keyMargin,
    required bool includeFnRow,
    required String spaceLabel,
  }) {
    return _buildUnifiedRows(
      DesktopFullLayoutData.layout75Rows(
        platform: _platform,
        includeFunctionRow: includeFnRow,
        layoutId: _layoutId,
        spaceLabel: spaceLabel,
      ),
      theme: theme,
      baseFontSize: baseFontSize,
      keyMargin: keyMargin,
    );
  }

  /// Renders **87% TKL**: Alphanumeric (15u) + gap + Nav Cluster (3u), no Numpad.
  Widget _buildLayout87TKL({
    required DesktopKeyboardThemeData theme,
    required double baseFontSize,
    required double keyMargin,
    required double clusterGap,
    required bool canShowNav,
    required bool includeFnRow,
    required String spaceLabel,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 15,
          child: _buildMainCluster(
            theme: theme,
            baseFontSize: baseFontSize,
            keyMargin: keyMargin,
            includeFnRow: includeFnRow,
            spaceLabel: spaceLabel,
          ),
        ),
        if (canShowNav) ...[
          SizedBox(width: clusterGap),
          Expanded(
            flex: 3,
            child: _buildNavigationCluster(
              theme: theme,
              baseFontSize: baseFontSize,
              keyMargin: keyMargin,
              includeFnRow: includeFnRow,
            ),
          ),
        ],
      ],
    );
  }

  /// Renders **98% Compact (1800-style)**: Zero inter-cluster gap, tucked arrows + 4-col Numpad.
  Widget _buildLayout98({
    required DesktopKeyboardThemeData theme,
    required double baseFontSize,
    required double keyMargin,
    required bool effectiveShowNumpad,
    required bool includeFnRow,
    required int rowCount,
    required String spaceLabel,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 15,
          child: _buildUnifiedRows(
            DesktopFullLayoutData.layout98MainRows(
              platform: _platform,
              includeFunctionRow: includeFnRow,
              layoutId: _layoutId,
              spaceLabel: spaceLabel,
            ),
            theme: theme,
            baseFontSize: baseFontSize,
            keyMargin: keyMargin,
          ),
        ),
        if (effectiveShowNumpad)
          Expanded(
            flex: 4,
            child: _buildCompact98Numpad(
              theme: theme,
              baseFontSize: baseFontSize,
              keyMargin: keyMargin,
              includeUtilityRow: includeFnRow,
            ),
          ),
      ],
    );
  }

  /// Renders **100% Full-Size**: Main (15u) + gap + NavCluster (3u) + gap + Numpad (4u).
  Widget _buildLayout100({
    required DesktopKeyboardThemeData theme,
    required double baseFontSize,
    required double keyMargin,
    required double clusterGap,
    required bool canShowNav,
    required bool effectiveShowNumpad,
    required bool includeFnRow,
    required int rowCount,
    required String spaceLabel,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 15,
          child: _buildMainCluster(
            theme: theme,
            baseFontSize: baseFontSize,
            keyMargin: keyMargin,
            includeFnRow: includeFnRow,
            spaceLabel: spaceLabel,
          ),
        ),
        if (canShowNav) ...[
          SizedBox(width: clusterGap),
          Expanded(
            flex: 3,
            child: _buildNavigationCluster(
              theme: theme,
              baseFontSize: baseFontSize,
              keyMargin: keyMargin,
              includeFnRow: includeFnRow,
            ),
          ),
        ],
        if (effectiveShowNumpad) ...[
          SizedBox(width: clusterGap),
          Expanded(
            flex: 4,
            child: _buildNumpadCluster(
              theme: theme,
              baseFontSize: baseFontSize,
              keyMargin: keyMargin,
              mainRowCount: rowCount,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHeaderBar({
    required DesktopKeyboardThemeData theme,
    required double availW,
    required bool canShowNumpad,
    required bool effectiveShowNumpad,
  }) {
    final showSubtitle = availW >= 1040;
    final showFullLocaleName = availW >= 740;
    final showPlatformBar = widget.showPlatformToggle && availW >= 620;
    final showNumpadToggle = widget.layoutType.hasNumpad && canShowNumpad;
    final showFnLed = _isFnActive || widget.layoutType.hasFnLayer;

    return Row(
      children: [
        Icon(
          Icons.desktop_windows_outlined,
          size: 15,
          color: theme.navigationIconColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  'Desktop ${widget.layoutType.label}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.headerTextColor,
                  ),
                ),
              ),
              if (showSubtitle) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '|',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.keyBorderColor,
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    'Proportional Flex-Grow Grid',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: theme.headerSubtitleColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (widget.showLocaleSelector) ...[
          InkWell(
            key: const ValueKey('dk_locale_picker'),
            onTap: () => _openLocalePicker(theme),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: theme.specialKeyColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _layoutId != 'en_US'
                      ? theme.activeBorderColor.withValues(alpha: 0.7)
                      : theme.keyBorderColor,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.language_rounded,
                    size: 13,
                    color: _layoutId != 'en_US'
                        ? theme.ledActiveColor
                        : theme.navigationIconColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    showFullLocaleName
                        ? VKeyboardLayouts.getDisplayName(_layoutId)
                        : VKeyboardLayouts.getShortLabel(_layoutId),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.headerTextColor,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 14,
                    color: theme.headerSubtitleColor,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (showPlatformBar) ...[
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: theme.specialKeyColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.keyBorderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final os in DesktopKeyboardPlatform.values)
                  InkWell(
                    key: ValueKey('dk_os_${os.name}'),
                    onTap: () {
                      if (_platform == os) return;
                      setState(() => _platform = os);
                      widget.onPlatformChanged?.call(os);
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _platform == os
                            ? theme.activeKeyColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: _platform == os
                            ? Border.all(
                                color: theme.activeBorderColor
                                    .withValues(alpha: 0.7),
                                width: 0.8,
                              )
                            : null,
                      ),
                      child: Text(
                        os.label,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: _platform == os
                              ? theme.activeTextColor
                              : theme.headerSubtitleColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (showNumpadToggle)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () => setState(() => _showNumpad = !_showNumpad),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.specialKeyColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: theme.keyBorderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.dialpad_rounded,
                      size: 13,
                      color: theme.navigationIconColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      effectiveShowNumpad ? 'Hide Numpad' : 'Show Numpad',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.headerTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (showFnLed) ...[
          _buildStatusLed(
            label: 'FN',
            active: _isFnActive,
            theme: theme,
          ),
          const SizedBox(width: 10),
        ],
        _buildStatusLed(
          label: 'CAPS',
          active: _isCapsLockActive,
          theme: theme,
        ),
        if (effectiveShowNumpad) ...[
          const SizedBox(width: 10),
          _buildStatusLed(
            label: 'NUM',
            active: _isNumLockActive,
            theme: theme,
          ),
        ],
      ],
    );
  }

  Widget _buildStatusLed({
    required String label,
    required bool active,
    required DesktopKeyboardThemeData theme,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? theme.ledActiveColor : theme.ledInactiveColor,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: theme.ledActiveColor.withValues(alpha: 0.75),
                      blurRadius: 5,
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: active ? theme.headerTextColor : theme.headerSubtitleColor,
          ),
        ),
      ],
    );
  }

  Widget _buildKeyButton(
    KeyModel model, {
    required DesktopKeyboardThemeData theme,
    required double baseFontSize,
    required double keyMargin,
  }) {
    final isSpace = model.type == KeyType.space && widget.showLocaleSelector;
    return VirtualKeyButton(
      key: ValueKey('dk_${widget.layoutType.name}_${model.id}'),
      model: model,
      theme: theme,
      baseFontSize: baseFontSize,
      isShiftActive: _isShiftActive,
      isCapsLockActive: _isCapsLockActive,
      isNumLockActive: _isNumLockActive,
      isFnActive: _isFnActive,
      isEngaged: _isKeyEngaged(model),
      horizontalMargin: keyMargin,
      verticalMargin: keyMargin,
      onTap: _handleKeyTap,
      onLongPress: isSpace ? () => _openLocalePicker(theme) : null,
    );
  }

  Widget _buildRow(
    List<KeyModel> keys, {
    required DesktopKeyboardThemeData theme,
    required double baseFontSize,
    required double keyMargin,
  }) {
    return Expanded(
      flex: 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final k in keys)
            _buildKeyButton(
              k,
              theme: theme,
              baseFontSize: baseFontSize,
              keyMargin: keyMargin,
            ),
        ],
      ),
    );
  }

  Widget _buildUnifiedRows(
    List<List<KeyModel>> rows, {
    required DesktopKeyboardThemeData theme,
    required double baseFontSize,
    required double keyMargin,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final row in rows)
          _buildRow(
            row,
            theme: theme,
            baseFontSize: baseFontSize,
            keyMargin: keyMargin,
          ),
      ],
    );
  }

  Widget _buildMainCluster({
    required DesktopKeyboardThemeData theme,
    required double baseFontSize,
    required double keyMargin,
    required bool includeFnRow,
    required String spaceLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (includeFnRow)
          _buildRow(
            DesktopFullLayoutData.functionRow(platform: _platform),
            theme: theme,
            baseFontSize: baseFontSize,
            keyMargin: keyMargin,
          ),
        _buildRow(
          DesktopFullLayoutData.numberRow(
            platform: _platform,
            layoutId: _layoutId,
          ),
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
        ),
        _buildRow(
          DesktopFullLayoutData.topAlphaRow(
            platform: _platform,
            layoutId: _layoutId,
          ),
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
        ),
        _buildRow(
          DesktopFullLayoutData.homeAlphaRow(
            platform: _platform,
            layoutId: _layoutId,
          ),
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
        ),
        _buildRow(
          DesktopFullLayoutData.bottomAlphaRow(
            platform: _platform,
            layoutId: _layoutId,
          ),
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
        ),
        _buildRow(
          DesktopFullLayoutData.bottomControlRow(
            platform: _platform,
            spaceLabel: spaceLabel,
          ),
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
        ),
      ],
    );
  }

  Widget _buildNavigationCluster({
    required DesktopKeyboardThemeData theme,
    required double baseFontSize,
    required double keyMargin,
    required bool includeFnRow,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (includeFnRow)
          _buildRow(
            DesktopFullLayoutData.navSystemRow(platform: _platform),
            theme: theme,
            baseFontSize: baseFontSize,
            keyMargin: keyMargin,
          ),
        _buildRow(
          DesktopFullLayoutData.navTopEditRow(platform: _platform),
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
        ),
        _buildRow(
          DesktopFullLayoutData.navBottomEditRow(platform: _platform),
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
        ),
        _buildRow(
          DesktopFullLayoutData.navEmptyRow(),
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
        ),
        _buildRow(
          DesktopFullLayoutData.navArrowUpRow(),
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
        ),
        _buildRow(
          DesktopFullLayoutData.navArrowBottomRow(),
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
        ),
      ],
    );
  }

  Widget _buildNumpadGridBody({
    required DesktopKeyboardThemeData theme,
    required double baseFontSize,
    required double keyMargin,
    required int flex,
  }) {
    return Expanded(
      flex: flex,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildRow(
                  DesktopFullLayoutData.numpadRow789(),
                  theme: theme,
                  baseFontSize: baseFontSize,
                  keyMargin: keyMargin,
                ),
                _buildRow(
                  DesktopFullLayoutData.numpadRow456(),
                  theme: theme,
                  baseFontSize: baseFontSize,
                  keyMargin: keyMargin,
                ),
                _buildRow(
                  DesktopFullLayoutData.numpadRow123(),
                  theme: theme,
                  baseFontSize: baseFontSize,
                  keyMargin: keyMargin,
                ),
                _buildRow(
                  DesktopFullLayoutData.numpadRow0Dot(),
                  theme: theme,
                  baseFontSize: baseFontSize,
                  keyMargin: keyMargin,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildKeyButton(
                  DesktopFullLayoutData.numpadPlusKey(),
                  theme: theme,
                  baseFontSize: baseFontSize,
                  keyMargin: keyMargin,
                ),
                _buildKeyButton(
                  DesktopFullLayoutData.numpadEnterKey(),
                  theme: theme,
                  baseFontSize: baseFontSize,
                  keyMargin: keyMargin,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumpadCluster({
    required DesktopKeyboardThemeData theme,
    required double baseFontSize,
    required double keyMargin,
    required int mainRowCount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildRow(
          DesktopFullLayoutData.numpadTopRow(platform: _platform),
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
        ),
        _buildNumpadGridBody(
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
          flex: mainRowCount - 1,
        ),
      ],
    );
  }

  /// **98% Compact 1800 Numpad**: Adds top utility row (`Ins`, `Del`, `Home`, `PgUp`)
  /// aligned with Row 0 (`Esc..F12`), followed by `Num / * -` and the 4-row Numpad.
  Widget _buildCompact98Numpad({
    required DesktopKeyboardThemeData theme,
    required double baseFontSize,
    required double keyMargin,
    required bool includeUtilityRow,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (includeUtilityRow)
          _buildRow(
            DesktopFullLayoutData.layout98NumpadUtilityRow(platform: _platform),
            theme: theme,
            baseFontSize: baseFontSize,
            keyMargin: keyMargin,
          ),
        _buildRow(
          DesktopFullLayoutData.numpadTopRow(platform: _platform),
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
        ),
        _buildNumpadGridBody(
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
          flex: 4,
        ),
      ],
    );
  }
}
