import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/v_keyboard_config.dart';
import '../controller/keyboard_session.dart';
import '../engine/text_input_engine.dart';
import '../models/key_data.dart';
import '../models/keyboard_layout.dart';
import '../models/keyboard_type.dart';
import '../scope/v_keyboard_scope.dart';

/// A drop-in text field driven by the [VKeyboardScope] keyboard instead
/// of the OS keyboard.
///
/// Internally it is a `readOnly` [TextField], so the system keyboard never
/// shows, yet the cursor, selection, scrolling, multiline editing and
/// selection handles all behave natively. The virtual keyboard mutates the
/// field's [TextEditingController] directly, preserving cursor and selection.
///
/// Use it exactly like a `TextField`:
/// ```dart
/// VirtualTextField(
///   controller: controller,
///   focusNode: focusNode,
///   keyboardType: VKeyboardType.standard,
///   textInputAction: TextInputAction.next,
/// )
/// ```
class VirtualTextField extends StatefulWidget {
  const VirtualTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.keyboardType = VKeyboardType.standard,
    this.textInputAction = TextInputAction.done,
    this.config,
    this.customLayout,
    this.decoration = const InputDecoration(),
    this.style,
    this.textAlign = TextAlign.start,
    this.obscureText = false,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.cursorColor,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.onEditingComplete,
    this.onSelectionChanged,
    this.onAction,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final VKeyboardType keyboardType;
  final TextInputAction textInputAction;

  /// Overrides the scope's config for this field.
  final VKeyboardConfig? config;

  /// Required when [keyboardType] is [VKeyboardType.custom].
  final KeyboardLayout? customLayout;

  final InputDecoration decoration;
  final TextStyle? style;
  final TextAlign textAlign;
  final bool obscureText;
  final bool autofocus;
  final bool enabled;

  /// When true the field cannot be edited at all (distinct from the internal
  /// readOnly used to suppress the OS keyboard).
  final bool readOnly;

  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Color? cursorColor;

  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final ValueChanged<TextSelection>? onSelectionChanged;
  final ValueChanged<TextInputAction>? onAction;

  @override
  State<VirtualTextField> createState() => _VirtualTextFieldState();
}

class _VirtualTextFieldState extends State<VirtualTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _ownsController = false;
  bool _ownsFocusNode = false;

  KeyboardSession? _session;
  TextSelection? _lastSelection;

  /// Cached scope data so it can be used safely in [dispose].
  VKeyboardScopeData? _scope;

  bool get _effectiveObscure =>
      widget.obscureText || widget.keyboardType == VKeyboardType.password;

  bool get _isMultiline =>
      widget.keyboardType == VKeyboardType.multiline ||
      widget.textInputAction == TextInputAction.newline ||
      (widget.maxLines == null) ||
      (widget.maxLines != null && widget.maxLines! > 1);

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _ownsController = widget.controller == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode.addListener(_onFocusChanged);
    _controller.addListener(_onEditingValueChanged);
  }

  @override
  void didUpdateWidget(covariant VirtualTextField old) {
    super.didUpdateWidget(old);
    if (widget.controller != old.controller) {
      _controller.removeListener(_onEditingValueChanged);
      if (_ownsController) _controller.dispose();
      _controller = widget.controller ?? TextEditingController();
      _ownsController = widget.controller == null;
      _controller.addListener(_onEditingValueChanged);
    }
    if (widget.focusNode != old.focusNode) {
      _focusNode.removeListener(_onFocusChanged);
      if (_ownsFocusNode) _focusNode.dispose();
      _focusNode = widget.focusNode ?? FocusNode();
      _ownsFocusNode = widget.focusNode == null;
      _focusNode.addListener(_onFocusChanged);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scope = VKeyboardScope.maybeOf(context);
  }

  @override
  void dispose() {
    // Detach from the keyboard before disposing so the controller can't keep a
    // dangling session (handles "disposed widgets are handled safely"). Uses
    // the cached scope — inherited lookups are unsafe in dispose().
    final session = _session;
    if (session != null) {
      _scope?.controller.detach(session);
    }
    _focusNode.removeListener(_onFocusChanged);
    _controller.removeListener(_onEditingValueChanged);
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  VKeyboardConfig _resolveConfig() {
    return widget.config ??
        VKeyboardScope.maybeOf(context)?.config ??
        const VKeyboardConfig();
  }

  KeyboardSession _buildSession() {
    final config = _resolveConfig();
    return KeyboardSession(
      id: this,
      editingController: _controller,
      focusNode: _focusNode,
      type: widget.keyboardType,
      textInputAction: widget.textInputAction,
      config: config,
      customLayout: widget.customLayout,
      obscureText: _effectiveObscure,
      contextRef: () => mounted ? context : null,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onEditingComplete: widget.onEditingComplete,
      onSelectionChanged: widget.onSelectionChanged,
      onAction: widget.onAction,
    );
  }

  void _onFocusChanged() {
    final scope = VKeyboardScope.maybeOf(context);
    if (scope == null) return;
    if (_focusNode.hasFocus) {
      final session = _buildSession();
      _session = session;
      scope.controller.attach(session);
    } else if (_session != null) {
      scope.controller.detach(_session!);
      _session = null;
    }
  }

  void _onEditingValueChanged() {
    final selection = _controller.selection;
    if (selection != _lastSelection) {
      _lastSelection = selection;
      if (selection.isValid) {
        widget.onSelectionChanged?.call(selection);
      }
    }
  }

  // ---- Hardware keyboard fallback (desktop/web) -----------------------------

  bool get _hardwareEnabled {
    if (kIsWeb) return _resolveConfig().hardwareKeyboardFallback;
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
        return _resolveConfig().hardwareKeyboardFallback;
      default:
        return false;
    }
  }

  KeyEventResult _onHardwareKey(FocusNode node, KeyEvent event) {
    if (!_hardwareEnabled) return KeyEventResult.ignored;
    if (!_focusNode.hasFocus) return KeyEventResult.ignored;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.backspace) {
      _controller.value = TextInputEngine.deleteBackward(_controller.value);
      widget.onChanged?.call(_controller.text);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.delete) {
      _controller.value = TextInputEngine.deleteForward(_controller.value);
      widget.onChanged?.call(_controller.text);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      final scope = VKeyboardScope.maybeOf(context);
      if (_isMultiline) {
        _controller.value = TextInputEngine.newline(_controller.value);
        widget.onChanged?.call(_controller.text);
      } else if (_session != null) {
        scope?.controller.handleKey(KeyData.enter());
      }
      return KeyEventResult.handled;
    }
    // Let arrows / shortcuts fall through to the field's selection handling.
    if (_isNavigation(key)) return KeyEventResult.ignored;

    final ch = event.character;
    if (ch != null && ch.isNotEmpty && !_isControlChar(ch)) {
      _controller.value = TextInputEngine.insert(_controller.value, ch);
      widget.onChanged?.call(_controller.text);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  bool _isNavigation(LogicalKeyboardKey key) =>
      key == LogicalKeyboardKey.arrowLeft ||
      key == LogicalKeyboardKey.arrowRight ||
      key == LogicalKeyboardKey.arrowUp ||
      key == LogicalKeyboardKey.arrowDown ||
      key == LogicalKeyboardKey.home ||
      key == LogicalKeyboardKey.end ||
      key == LogicalKeyboardKey.tab;

  bool _isControlChar(String ch) {
    final code = ch.codeUnitAt(0);
    return code < 0x20 || code == 0x7F;
  }

  @override
  Widget build(BuildContext context) {
    final scope = VKeyboardScope.maybeOf(context);
    final config = _resolveConfig();

    final field = TextField(
      controller: _controller,
      focusNode: _focusNode,
      // readOnly suppresses the OS keyboard while keeping cursor + selection.
      readOnly: true,
      showCursor: !widget.readOnly,
      enableInteractiveSelection: true,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      obscureText: _effectiveObscure,
      decoration: widget.decoration,
      style: widget.style,
      textAlign: widget.textAlign,
      cursorColor: widget.cursorColor,
      maxLines: _effectiveObscure ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      mouseCursor: SystemMouseCursors.text,
      onTap: widget.onTap,
      // Swallow the default outside-tap behaviour; TextField.onTapOutside does
      // not respect TapRegion groups, so it would unfocus on keyboard taps.
      // Outside-tap dismissal is handled by the grouped TapRegion below.
      onTapOutside: (_) {},
    );

    Widget result = field;

    if (_hardwareEnabled) {
      result = Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: _onHardwareKey,
        child: result,
      );
    }

    if (scope != null) {
      result = TapRegion(
        groupId: scope.tapGroup,
        onTapOutside: (_) {
          if (config.closeOnOutsideTap && _focusNode.hasFocus) {
            _focusNode.unfocus();
          }
        },
        child: result,
      );
    }
    return result;
  }
}
