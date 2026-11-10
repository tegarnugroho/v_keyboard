import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide ModifierKey;
import 'package:flutter_v_keyboard/flutter_v_keyboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExampleApp());
}

/// Accent color palette for customization demo.
enum AppAccentColor {
  blue('Royal Blue', Color(0xFF2563EB)),
  indigo('Indigo', Color(0xFF6366F1)),
  emerald('Emerald', Color(0xFF10B981)),
  purple('Purple', Color(0xFF8B5CF6)),
  amber('Amber', Color(0xFFF59E0B)),
  rose('Rose', Color(0xFFF43F5E));

  const AppAccentColor(this.label, this.color);
  final String label;
  final Color color;
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({
    super.key,
    this.initialTab = 0,
    this.initialDarkMode = true,
  });

  final int initialTab;
  final bool initialDarkMode;

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  late bool _isDarkMode = widget.initialDarkMode;
  AppAccentColor _accentColor = AppAccentColor.blue;
  double _keyBorderRadius = 8.0;

  void _toggleDarkMode(bool value) {
    setState(() => _isDarkMode = value);
  }

  void _updateAccentColor(AppAccentColor color) {
    setState(() => _accentColor = color);
  }

  void _updateKeyBorderRadius(double radius) {
    setState(() => _keyBorderRadius = radius);
  }

  VKeyboardTheme _buildKeyboardTheme() {
    final base = _isDarkMode
        ? VKeyboardTheme.dark(accentColor: _accentColor.color)
        : VKeyboardTheme.light(accentColor: _accentColor.color);
    return base.copyWith(
      borderRadius: BorderRadius.circular(_keyBorderRadius),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardTheme = _buildKeyboardTheme();
    const config = VKeyboardConfig(
      enableClipboardHistory: true,
      syncSystemClipboard: true,
      enabledLocales: VKeyboardLocale.values,
      showGlobeKey: false,
    );

    return MaterialApp(
      title: 'flutter_v_keyboard Demo',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: _accentColor.color,
          brightness: Brightness.light,
          surface: Colors.white,
        ),
        cardColor: Colors.white,
        dividerColor: const Color(0xFFE2E8F0),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        colorScheme: ColorScheme.fromSeed(
          seedColor: _accentColor.color,
          brightness: Brightness.dark,
          surface: const Color(0xFF161B26),
        ),
        cardColor: const Color(0xFF161B26),
        dividerColor: const Color(0xFF232836),
        useMaterial3: true,
      ),
      builder: (context, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isDesktopLayout = screenWidth >= 1080;

        return VKeyboardScope(
          theme: keyboardTheme,
          config: config,
          // On desktop the keyboard is embedded in the preview card.
          // On tablet/mobile it behaves as the native bottom virtual keyboard.
          renderKeyboard: !isDesktopLayout,
          child: VKeyboardShortcuts(
            shortcuts: {
              LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
                  () => debugPrint('Ctrl+S -> save triggered'),
              LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyP):
                  () => debugPrint('Ctrl+P -> print triggered'),
            },
            child: child!,
          ),
        );
      },
      home: ShowcasePlaygroundPage(
        initialTab: widget.initialTab,
        isDarkMode: _isDarkMode,
        onToggleDarkMode: _toggleDarkMode,
        accentColor: _accentColor,
        onSelectAccentColor: _updateAccentColor,
        keyBorderRadius: _keyBorderRadius,
        onUpdateKeyBorderRadius: _updateKeyBorderRadius,
      ),
    );
  }
}

enum _ActiveTab {
  playground('Playground', Icons.edit_note_rounded),
  types('Keyboard Types', Icons.grid_view_rounded),
  customization('Customization', Icons.palette_outlined),
  desktop('Desktop Keyboard', Icons.desktop_windows_outlined),
  examples('Examples', Icons.widgets_outlined);

  const _ActiveTab(this.title, this.icon);
  final String title;
  final IconData icon;
}

class ShowcasePlaygroundPage extends StatefulWidget {
  const ShowcasePlaygroundPage({
    super.key,
    this.initialTab = 0,
    required this.isDarkMode,
    required this.onToggleDarkMode,
    required this.accentColor,
    required this.onSelectAccentColor,
    required this.keyBorderRadius,
    required this.onUpdateKeyBorderRadius,
  });

  final int initialTab;
  final bool isDarkMode;
  final ValueChanged<bool> onToggleDarkMode;
  final AppAccentColor accentColor;
  final ValueChanged<AppAccentColor> onSelectAccentColor;
  final double keyBorderRadius;
  final ValueChanged<double> onUpdateKeyBorderRadius;

  @override
  State<ShowcasePlaygroundPage> createState() => _ShowcasePlaygroundPageState();
}

class _ShowcasePlaygroundPageState extends State<ShowcasePlaygroundPage> {
  late _ActiveTab _currentTab;
  VKeyboardType _selectedType = VKeyboardType.standard;
  bool _showClipboardInPreview = false;
  double _splitRatio = 0.48;
  bool _isHoveringSplitter = false;
  bool _isDraggingSplitter = false;
  bool _isSidebarVisible = true;

  // Text controllers for playground & tabs
  final TextEditingController _playgroundController = TextEditingController();
  final FocusNode _playgroundFocusNode = FocusNode();

  // Multi-type demo controllers
  final TextEditingController _stdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _numController = TextEditingController();
  final TextEditingController _decController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _multiController = TextEditingController();

  // Desktop tab controller & state
  final TextEditingController _desktopController = TextEditingController();
  final FocusNode _desktopFocusNode = FocusNode();
  String _desktopLastEvent = 'None';
  bool _desktopShowFnRow = true;

  // Custom layout definition (Math & Scientific symbols example)
  static final KeyboardLayout _customLayout = KeyboardLayout(
    id: 'math_custom',
    initialPage: 'main',
    pages: {
      'main': [
        ['π', 'θ', 'λ', 'μ', 'σ', 'ω', 'Δ', 'Ω', '²', '³']
            .map((c) => KeyData.char(c))
            .toList(),
        ['√', '∛', '±', '≠', '≈', '≤', '≥', '∞', '÷', '×']
            .map((c) => KeyData.char(c))
            .toList(),
        [
          KeyData.shift(flex: 1.5),
          ...'+−=%/()'.split('').map((c) => KeyData.char(c)),
          KeyData.backspace(flex: 1.5),
        ],
        [
          KeyData.switchTo('symbols', label: '123', flex: 1.5),
          KeyData.space(),
          KeyData.enter(flex: 2),
        ],
      ],
      'symbols': [
        '1234567890'.split('').map((c) => KeyData.char(c)).toList(),
        '+-*/=()[]{}'.split('').map((c) => KeyData.char(c)).toList(),
        [
          KeyData.switchTo('main', label: 'Math', flex: 2),
          KeyData.space(),
          KeyData.backspace(flex: 1.5),
        ],
      ],
    },
  );

  bool _seededClipboard = false;

  @override
  void initState() {
    super.initState();
    final tabIndex = widget.initialTab.clamp(0, _ActiveTab.values.length - 1);
    _currentTab = _ActiveTab.values[tabIndex];
    if (_currentTab == _ActiveTab.desktop) {
      _selectedType = VKeyboardType.desktop;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _seedSampleClipboardItems();
    });
  }

  void _seedSampleClipboardItems() {
    if (_seededClipboard) return;
    _seededClipboard = true;
    final scope = VKeyboardScope.maybeOf(context);
    if (scope == null) return;

    final history = scope.controller.clipboardHistory;
    history.record('https://example.com/product/123');
    history.record('customer@example.com');
    history.record('INV-2026-00142');
    history.record('JL. Sudirman No. 123, Jakarta');
    // Pin the first item
    if (history.items.isNotEmpty) {
      history.togglePin(history.items.first.id);
    }
  }

  @override
  void dispose() {
    _playgroundController.dispose();
    _playgroundFocusNode.dispose();
    _stdController.dispose();
    _emailController.dispose();
    _urlController.dispose();
    _numController.dispose();
    _decController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    _passController.dispose();
    _multiController.dispose();
    _desktopController.dispose();
    _desktopFocusNode.dispose();
    super.dispose();
  }

  void _onSelectKeyboardType(VKeyboardType type) {
    setState(() {
      _selectedType = type;
    });
    _playgroundFocusNode.requestFocus();
  }

  void _onQuickExampleTapped(int index) {
    switch (index) {
      case 0: // Cursor & Selection
        _playgroundController.value = const TextEditingValue(
          text: 'Select text and edit with precision cursor control.',
          selection: TextSelection(baseOffset: 7, extentOffset: 11), // 'text'
        );
        _playgroundFocusNode.requestFocus();
        break;
      case 1: // Clipboard History
        setState(() => _showClipboardInPreview = true);
        final scope = VKeyboardScope.maybeOf(context);
        scope?.controller.openClipboardHistory();
        _playgroundFocusNode.requestFocus();
        break;
      case 2: // Custom Layouts
        _onSelectKeyboardType(VKeyboardType.custom);
        _playgroundController.text = 'f(x) = π * r²';
        _playgroundFocusNode.requestFocus();
        break;
      case 3: // Desktop Support
        setState(() {
          _currentTab = _ActiveTab.desktop;
          _selectedType = VKeyboardType.desktop;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width >= 1080) {
          return _buildDesktopLayout();
        } else if (width >= 720) {
          return _buildTabletLayout();
        } else {
          return _buildMobileLayout();
        }
      },
    );
  }

  // ===========================================================================
  // Desktop Layout (1440px+ mockup fidelity)
  // ===========================================================================
  Widget _buildDesktopLayout() {
    final isDark = widget.isDarkMode;
    final bgColor = isDark ? const Color(0xFF0F1117) : const Color(0xFFF1F5F9);
    final cardBg = isDark ? const Color(0xFF161922) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF232836) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // macOS traffic light bar
              _buildMacOsWindowHeader(isDark),
              const SizedBox(height: 12),
              // Main 3-column body
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final totalWidth = constraints.maxWidth;
                    final effectiveSidebarWidth = _isSidebarVisible ? 260.0 : 0.0;
                    final effectiveGap = _isSidebarVisible ? 16.0 : 0.0;
                    const dividerWidth = 14.0;
                    final showPreview = _currentTab != _ActiveTab.desktop;

                    final double leftWidth;
                    if (showPreview) {
                      final availableSplitWidth = totalWidth -
                          effectiveSidebarWidth -
                          effectiveGap -
                          dividerWidth;
                      const minWidth = 320.0;
                      final maxLeft = math.max(
                          minWidth, availableSplitWidth - minWidth);
                      leftWidth = (availableSplitWidth * _splitRatio)
                          .clamp(minWidth, maxLeft);
                    } else {
                      leftWidth = totalWidth - effectiveSidebarWidth - effectiveGap;
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Column 1: Left Sidebar
                        if (_isSidebarVisible) ...[
                          SizedBox(
                            width: effectiveSidebarWidth,
                            child: _buildSidebar(isDark, cardBg, borderColor),
                          ),
                          const SizedBox(width: 16.0),
                        ],

                        // Column 2: Center Content Panel
                        if (showPreview)
                          SizedBox(
                            width: leftWidth,
                            child: Container(
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderColor),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: _buildMainContentArea(isDark),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderColor),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: _buildMainContentArea(isDark),
                              ),
                            ),
                          ),

                        if (showPreview) ...[
                          // Column 2.5: Interactive Draggable Split Divider
                          _buildSplitDivider(
                            isDark: isDark,
                            borderColor: borderColor,
                            onDrag: (delta) {
                              final availableSplitWidth = totalWidth -
                                  effectiveSidebarWidth -
                                  effectiveGap -
                                  dividerWidth;
                              if (availableSplitWidth > 0) {
                                final minRatio = (300.0 / availableSplitWidth)
                                    .clamp(0.15, 0.45);
                                final maxRatio = ((availableSplitWidth - 300.0) /
                                        availableSplitWidth)
                                    .clamp(0.55, 0.85);
                                setState(() {
                                  _splitRatio = (_splitRatio +
                                          (delta / availableSplitWidth))
                                      .clamp(minRatio, maxRatio);
                                });
                              }
                            },
                            onReset: () {
                              setState(() {
                                _splitRatio = 0.48;
                              });
                            },
                          ),

                          // Column 3: Right Keyboard Preview Panel
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderColor),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: _buildDesktopKeyboardPreview(
                                  isDark,
                                  cardBg,
                                  borderColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSplitDivider({
    required bool isDark,
    required Color borderColor,
    required ValueChanged<double> onDrag,
    required VoidCallback onReset,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onEnter: (_) {
        if (!_isHoveringSplitter) setState(() => _isHoveringSplitter = true);
      },
      onExit: (_) {
        if (_isHoveringSplitter) setState(() => _isHoveringSplitter = false);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) {
          if (!_isDraggingSplitter) setState(() => _isDraggingSplitter = true);
        },
        onHorizontalDragUpdate: (details) => onDrag(details.delta.dx),
        onHorizontalDragEnd: (_) {
          if (_isDraggingSplitter) setState(() => _isDraggingSplitter = false);
        },
        onHorizontalDragCancel: () {
          if (_isDraggingSplitter) setState(() => _isDraggingSplitter = false);
        },
        onDoubleTap: onReset,
        child: Tooltip(
          message: 'Drag to resize · Double-click to reset',
          waitDuration: const Duration(milliseconds: 600),
          child: Container(
            width: 18,
            alignment: Alignment.center,
            color: Colors.transparent,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: (_isHoveringSplitter || _isDraggingSplitter) ? 4 : 2,
              height: (_isHoveringSplitter || _isDraggingSplitter) ? 48 : 28,
              decoration: BoxDecoration(
                color: (_isHoveringSplitter || _isDraggingSplitter)
                    ? widget.accentColor.color
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.20)
                        : Colors.black.withValues(alpha: 0.20)),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMacOsWindowHeader(bool isDark) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xFFFF5F56),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xFFFFBD2E),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xFF27C93F),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 16),
        Tooltip(
          message: _isSidebarVisible ? 'Hide sidebar' : 'Show sidebar',
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () => setState(() => _isSidebarVisible = !_isSidebarVisible),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _isSidebarVisible
                    ? (isDark ? const Color(0xFF1E2433) : const Color(0xFFE2E8F0))
                    : (isDark ? const Color(0xFF161922) : Colors.white),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark ? const Color(0xFF283145) : const Color(0xFFCBD5E1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isSidebarVisible
                        ? Icons.view_sidebar_rounded
                        : Icons.view_sidebar_outlined,
                    size: 14,
                    color: _isSidebarVisible
                        ? widget.accentColor.color
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isSidebarVisible ? 'Hide sidebar' : 'Show sidebar',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!_isSidebarVisible) ...[
          const SizedBox(width: 12),
          // Compact tab navigation when sidebar is hidden
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _ActiveTab.values.map((tab) {
                  final isSelected = _currentTab == tab;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Tooltip(
                      message: tab.title,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () {
                          setState(() {
                            _currentTab = tab;
                            if (tab == _ActiveTab.playground) {
                              _selectedType = VKeyboardType.standard;
                            } else if (tab == _ActiveTab.desktop) {
                              _selectedType = VKeyboardType.desktop;
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? const Color(0xFF1E2638) : const Color(0xFFE2E8F0))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                tab.icon,
                                size: 14,
                                color: isSelected
                                    ? widget.accentColor.color
                                    : (isDark ? Colors.white60 : Colors.black54),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                tab.title,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight:
                                      isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected
                                      ? (isDark ? Colors.white : Colors.black87)
                                      : (isDark ? Colors.white60 : Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSidebar(bool isDark, Color cardBg, Color borderColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Title
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.accentColor.color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.keyboard_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Virtual Keyboard',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'A customizable keyboard for Flutter',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Tooltip(
                message: 'Hide sidebar',
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () => setState(() => _isSidebarVisible = false),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.keyboard_double_arrow_left_rounded,
                      size: 20,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: _ActiveTab.values.map((tab) {
                final isSelected = _currentTab == tab;
                final activeBg = isDark
                    ? const Color(0xFF1E2638)
                    : const Color(0xFFE2E8F0);
                final activeColor = widget.accentColor.color;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      setState(() {
                        _currentTab = tab;
                        if (tab == _ActiveTab.playground) {
                          _selectedType = VKeyboardType.standard;
                        } else if (tab == _ActiveTab.desktop) {
                          _selectedType = VKeyboardType.desktop;
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? activeBg : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected
                            ? Border.all(
                                color: activeColor.withValues(alpha: 0.4))
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            tab.icon,
                            size: 18,
                            color: isSelected
                                ? activeColor
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tab.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? (isDark ? Colors.white : Colors.black)
                                    : (isDark ? Colors.white70 : Colors.black87),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Dark Mode Switch
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF11141E) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  widget.isDarkMode
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                  size: 18,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Dark mode',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
                Switch(
                  value: widget.isDarkMode,
                  activeThumbColor: widget.accentColor.color,
                  onChanged: widget.onToggleDarkMode,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Center panel contents according to active tab
  Widget _buildMainContentArea(bool isDark) {
    switch (_currentTab) {
      case _ActiveTab.playground:
        return _buildPlaygroundCenterPanel(isDark);
      case _ActiveTab.types:
        return _buildTypesTab(isDark);
      case _ActiveTab.customization:
        return _buildCustomizationTab(isDark);
      case _ActiveTab.desktop:
        return _buildDesktopTab(isDark);
      case _ActiveTab.examples:
        return _buildExamplesTab(isDark);
    }
  }

  Widget _buildPlaygroundCenterPanel(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Try it out
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Try it out',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enter text using the virtual keyboard below.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _playgroundController.clear(),
                icon: const Icon(Icons.clear_rounded, size: 16),
                label: const Text('Clear'),
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Main Interactive Text Field
          VTextField(
            controller: _playgroundController,
            focusNode: _playgroundFocusNode,
            keyboardType: _selectedType,
            customLayout:
                _selectedType == VKeyboardType.custom ? _customLayout : null,
            autofocus: true,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Type something here...',
              hintStyle: TextStyle(
                color: isDark ? Colors.white30 : Colors.black38,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              filled: true,
              fillColor:
                  isDark ? const Color(0xFF11141E) : const Color(0xFFF8FAFC),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF262D3D)
                      : const Color(0xFFCBD5E1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: widget.accentColor.color,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section: Keyboard Type
          Text(
            'Keyboard type',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildKeyboardTypeSelectorGrid(isDark),
          const SizedBox(height: 28),

          // Section: Quick Examples
          Text(
            'Quick examples',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickExamplesGrid(isDark),
        ],
      ),
    );
  }

  Widget _buildKeyboardTypeSelectorGrid(bool isDark) {
    final types = [
      (VKeyboardType.standard, 'Standard', Icons.keyboard_outlined),
      (VKeyboardType.email, 'Email', Icons.mail_outline_rounded),
      (VKeyboardType.number, 'Number', Icons.tag_rounded),
      (VKeyboardType.decimal, 'Decimal', Icons.calculate_outlined),
      (VKeyboardType.url, 'URL', Icons.link_rounded),
      (VKeyboardType.phone, 'Phone', Icons.phone_outlined),
      (VKeyboardType.pin, 'PIN', Icons.dialpad_outlined),
      (VKeyboardType.password, 'Password', Icons.lock_outline_rounded),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: types.map((item) {
        final isSelected = _selectedType == item.$1;
        final activeColor = widget.accentColor.color;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _onSelectKeyboardType(item.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor
                    : (isDark
                        ? const Color(0xFF1E2433)
                        : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? activeColor
                      : (isDark
                          ? const Color(0xFF283145)
                          : const Color(0xFFCBD5E1)),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.$3,
                    size: 16,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.$2,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickExamplesGrid(bool isDark) {
    final examples = [
      (
        'Cursor & Selection',
        'Edit text with cursor control.',
        Icons.text_fields_rounded,
        const Color(0xFF38BDF8),
      ),
      (
        'Clipboard History',
        'Copy, paste and access recent items.',
        Icons.content_paste_rounded,
        const Color(0xFF818CF8),
      ),
      (
        'Custom Layouts',
        'Create your own keyboard layout.',
        Icons.dashboard_customize_outlined,
        const Color(0xFFA78BFA),
      ),
      (
        'Desktop Support',
        'Full keyboard, shortcuts, and navigation keys.',
        Icons.keyboard_rounded,
        const Color(0xFF34D399),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 420;
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isNarrow ? 1 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: isNarrow ? 72.0 : 76.0,
          ),
          itemCount: examples.length,
          itemBuilder: (context, index) {
            final item = examples[index];
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _onQuickExampleTapped(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF181D2A) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isDark ? const Color(0xFF262E40) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: item.$4.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(item.$3, color: item.$4, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.$1,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.$2,
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.25,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // Right Panel: Interactive Virtual Keyboard Preview
  // ===========================================================================
  Widget _buildDesktopKeyboardPreview(
    bool isDark,
    Color cardBg,
    Color borderColor,
  ) {
    final scope = VKeyboardScope.maybeOf(context);
    final controller = scope?.controller;
    final theme = scope?.theme ??
        (isDark ? VKeyboardTheme.dark() : VKeyboardTheme.light());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Preview Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Keyboard preview',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Interactive virtual keyboard',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
              // Layout Selector Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2536)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2A344A)
                        : const Color(0xFFCBD5E1),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<VKeyboardType>(
                    value: _selectedType,
                    isDense: true,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    dropdownColor:
                        isDark ? const Color(0xFF181D2A) : Colors.white,
                    items: const [
                      DropdownMenuItem(
                          value: VKeyboardType.standard,
                          child: Text('Standard')),
                      DropdownMenuItem(
                          value: VKeyboardType.email, child: Text('Email')),
                      DropdownMenuItem(
                          value: VKeyboardType.url, child: Text('URL')),
                      DropdownMenuItem(
                          value: VKeyboardType.number, child: Text('Number')),
                      DropdownMenuItem(
                          value: VKeyboardType.decimal, child: Text('Decimal')),
                      DropdownMenuItem(
                          value: VKeyboardType.phone, child: Text('Phone')),
                      DropdownMenuItem(
                          value: VKeyboardType.pin, child: Text('PIN')),
                      DropdownMenuItem(
                          value: VKeyboardType.password,
                          child: Text('Password')),
                      DropdownMenuItem(
                          value: VKeyboardType.custom, child: Text('Custom')),
                      DropdownMenuItem(
                          value: VKeyboardType.desktop, child: Text('Desktop')),
                    ],
                    onChanged: (val) {
                      if (val == null) return;
                      _onSelectKeyboardType(val);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Preview Workspace
        Expanded(
          child: controller == null
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth = constraints.maxWidth - 32.0;
                    final isDesktop = _selectedType == VKeyboardType.desktop;
                    final targetWidth = isDesktop
                        ? math.max(640.0, availableWidth)
                        : math.min(760.0, math.max(280.0, availableWidth));

                    return AnimatedBuilder(
                      animation: controller,
                      builder: (context, _) {
                        final isClipboard = _showClipboardInPreview ||
                            controller.currentPage == 'clipboard';
                        final isEmoji = controller.currentPage == 'emoji';
                        final bottomBarHeight = isDesktop ? 0.0 : 36.0;

                        final Widget content;
                        if (isEmoji) {
                          content = ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: targetWidth),
                            child: EmojiPanel(
                              controller: controller,
                              theme: theme,
                              height: 230,
                              maxWidth: targetWidth,
                              bottomSafeArea: bottomBarHeight,
                            ),
                          );
                        } else if (isClipboard) {
                          content = ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: targetWidth),
                            child: ClipboardHistoryPanel(
                              controller: controller,
                              theme: theme,
                              height: 230,
                              maxWidth: targetWidth,
                              bottomSafeArea: bottomBarHeight,
                            ),
                          );
                        } else {
                          content = _buildEmbeddedKeyboardView(
                            controller,
                            theme,
                            isDark,
                            availableWidth: availableWidth,
                          );
                        }

                        return TapRegion(
                          groupId: scope?.tapGroup ?? Object(),
                          child: ColoredBox(
                            color: theme.backgroundColor,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: content,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmbeddedKeyboardView(
    VKeyboardController controller,
    VKeyboardTheme theme,
    bool isDark, {
    required double availableWidth,
  }) {
    if (_selectedType == VKeyboardType.desktop) {
      final layoutWidth = math.max(640.0, availableWidth);
      final desktopRows =
          DesktopLayouts.rows(layoutWidth, layoutId: controller.currentLayoutId);
      final rowCount = desktopRows.length;
      final keyboardHeight = (rowCount * 46.0) + ((rowCount - 1) * 5.0) + 24.0;

      return Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: availableWidth >= layoutWidth
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          child: SizedBox(
            width: layoutWidth,
            height: keyboardHeight,
            child: KeyboardView(
              controller: controller,
              theme: theme,
              metrics: KeyboardMetrics(
                height: keyboardHeight,
                maxWidth: layoutWidth,
                horizontalPadding: 8,
                rowSpacing: 5,
                formFactor: DeviceFormFactor.desktop,
                isLandscape: true,
              ),
              rows: desktopRows,
              bottomSafeArea: 0,
            ),
          ),
        ),
      );
    }

    // Resolve rows based on selected type/layout and active layout ID
    final layout = BuiltinLayouts.resolve(
      _selectedType,
      custom: _selectedType == VKeyboardType.custom ? _customLayout : null,
      layoutId: controller.currentLayoutId,
    );
    final page = (controller.currentPage.isNotEmpty &&
            controller.currentPage != 'clipboard' &&
            controller.currentPage != 'emoji')
        ? controller.currentPage
        : layout.initialPage;
    final rows = layout.rowsFor(page);

    final responsiveWidth = math.min(760.0, math.max(280.0, availableWidth));

    final metrics = KeyboardMetrics(
      height: 230,
      maxWidth: responsiveWidth,
      horizontalPadding: 8,
      rowSpacing: 6,
      formFactor: DeviceFormFactor.phone,
      isLandscape: true,
    );

    return KeyboardView(
      controller: controller,
      theme: theme,
      metrics: metrics,
      rows: rows,
      bottomSafeArea: 0,
    );
  }

  // ===========================================================================
  // Tablet Layout (768px – 1439px mockup fidelity)
  // ===========================================================================
  Widget _buildTabletLayout() {
    final isDark = widget.isDarkMode;
    final cardBg = isDark ? const Color(0xFF161922) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF232836) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1117) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: cardBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.menu_rounded),
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: widget.accentColor.color,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.keyboard_outlined,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Virtual Keyboard',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                Text('A customizable keyboard for Flutter',
                    style: TextStyle(fontSize: 9, color: Colors.grey)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            ),
            onPressed: () => widget.onToggleDarkMode(!isDark),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _ActiveTab.values.map((tab) {
                final isSelected = _currentTab == tab;
                final activeColor = widget.accentColor.color;

                return InkWell(
                  onTap: () => setState(() => _currentTab = tab),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? activeColor : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      tab.title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? activeColor
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: _buildMainContentArea(isDark),
    );
  }

  // ===========================================================================
  // Mobile Layout (< 768px mockup fidelity)
  // ===========================================================================
  Widget _buildMobileLayout() {
    final isDark = widget.isDarkMode;
    final cardBg = isDark ? const Color(0xFF161922) : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1117) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: cardBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: widget.accentColor.color,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.keyboard_outlined,
                  color: Colors.white, size: 14),
            ),
            const SizedBox(width: 8),
            const Text(
              'Virtual Keyboard',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              size: 20,
            ),
            onPressed: () => widget.onToggleDarkMode(!isDark),
          ),
        ],
      ),
      body: Column(
        children: [
          // Segmented Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildMobileTabButton(_ActiveTab.playground, 'Playground'),
                const SizedBox(width: 8),
                _buildMobileTabButton(_ActiveTab.types, 'Types'),
                const SizedBox(width: 8),
                _buildMobileTabButton(_ActiveTab.examples, 'Examples'),
              ],
            ),
          ),
          const Divider(height: 1),
          // Scrollable Content
          Expanded(
            child: _buildMainContentArea(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTabButton(_ActiveTab tab, String label) {
    final isSelected = _currentTab == tab;
    final isDark = widget.isDarkMode;
    final activeColor = widget.accentColor.color;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() => _currentTab = tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor
                : (isDark ? const Color(0xFF1E2433) : const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Tab Content Pages: Types, Customization, Desktop, Examples
  // ===========================================================================

  Widget _buildTypesTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Keyboard Types Showcase',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap any field below to see the virtual keyboard adapt dynamically.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        const SizedBox(height: 20),
        _buildShowcaseField(
          'Standard Text',
          _stdController,
          VKeyboardType.standard,
          isDark,
          action: TextInputAction.next,
        ),
        _buildShowcaseField(
          'Email Address',
          _emailController,
          VKeyboardType.email,
          isDark,
          action: TextInputAction.next,
        ),
        _buildShowcaseField(
          'URL Address',
          _urlController,
          VKeyboardType.url,
          isDark,
          action: TextInputAction.next,
        ),
        _buildShowcaseField(
          'Numeric Input',
          _numController,
          VKeyboardType.number,
          isDark,
        ),
        _buildShowcaseField(
          'Decimal Input',
          _decController,
          VKeyboardType.decimal,
          isDark,
        ),
        _buildShowcaseField(
          'Phone Number',
          _phoneController,
          VKeyboardType.phone,
          isDark,
        ),
        _buildShowcaseField(
          'PIN Code',
          _pinController,
          VKeyboardType.pin,
          isDark,
          obscureText: true,
        ),
        _buildShowcaseField(
          'Password',
          _passController,
          VKeyboardType.password,
          isDark,
          obscureText: true,
        ),
        _buildShowcaseField(
          'Multiline Text',
          _multiController,
          VKeyboardType.multiline,
          isDark,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildShowcaseField(
    String label,
    TextEditingController controller,
    VKeyboardType type,
    bool isDark, {
    TextInputAction action = TextInputAction.done,
    bool obscureText = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          VTextField(
            controller: controller,
            keyboardType: type,
            textInputAction: action,
            obscureText: obscureText,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: 'Tap to edit $label...',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              filled: true,
              fillColor:
                  isDark ? const Color(0xFF11141E) : const Color(0xFFF8FAFC),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF262D3D)
                      : const Color(0xFFCBD5E1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: widget.accentColor.color,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizationTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Live Customization & Theme',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Fine-tune colors and key border radiuses in real-time.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        const SizedBox(height: 24),

        // Accent Colors
        const Text(
          'Accent Color',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: AppAccentColor.values.map((color) {
            final isSelected = widget.accentColor == color;
            return InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => widget.onSelectAccentColor(color),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: color.color.withValues(alpha: isSelected ? 0.2 : 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? color.color : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      color.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Key Border Radius
        Text(
          'Key Corner Radius: ${widget.keyBorderRadius.toInt()}px',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Slider(
          value: widget.keyBorderRadius,
          min: 0,
          max: 20,
          divisions: 5,
          activeColor: widget.accentColor.color,
          onChanged: widget.onUpdateKeyBorderRadius,
        ),
        const SizedBox(height: 24),

        // Multi-Language Layout Switcher
        const Text(
          'Multi-Language Keyboard Layouts',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Switch active layout at runtime via the globe button or layout picker dialog.',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        const SizedBox(height: 12),
        Builder(
          builder: (ctx) {
            final scope = VKeyboardScope.maybeOf(ctx);
            final activeId = scope?.controller.currentLayoutId ?? 'en_US';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: VKeyboardLocale.values.map((loc) {
                    final isSelected = activeId == loc.id;
                    return ChoiceChip(
                      label: Text('${loc.displayName} (${loc.shortLabel})'),
                      selected: isSelected,
                      selectedColor:
                          widget.accentColor.color.withValues(alpha: 0.25),
                      onSelected: (_) {
                        scope?.controller.setLocale(loc);
                        setState(() {});
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.language_rounded),
                  label: const Text('Open Layout Picker Dialog'),
                  onPressed: scope != null
                      ? () => showVKeyboardLayoutPicker(
                            ctx,
                            controller: scope.controller,
                            theme: scope.theme,
                          )
                      : null,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDesktopTab(bool isDark) {
    final scope = VKeyboardScope.maybeOf(context);
    final controller = scope?.controller;
    final desktopTheme = isDark
        ? DesktopKeyboardThemeData.dark(accentColor: widget.accentColor.color)
        : DesktopKeyboardThemeData.light(accentColor: widget.accentColor.color);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Full Desktop Keyboard (OSK Style)',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Edge-to-edge 100% full-size ANSI desktop grid with Function row, Navigation cluster, and Numpad.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilterChip(
                    label: const Text('Function Row'),
                    selected: _desktopShowFnRow,
                    onSelected: (v) => setState(() => _desktopShowFnRow = v),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Live Typing Preview Card (inspired by OSK Engine preview)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF13161F) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF23293A)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.terminal_rounded,
                          size: 16,
                          color: widget.accentColor.color,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Live Typing Preview',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _desktopController,
                          builder: (context, val, _) {
                            return Text(
                              '• ${val.text.length} chars',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white54 : Colors.black45,
                              ),
                            );
                          },
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: widget.accentColor.color
                                .withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: widget.accentColor.color
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            'Last Event: $_desktopLastEvent',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: widget.accentColor.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    VTextField(
                      controller: _desktopController,
                      focusNode: _desktopFocusNode,
                      keyboardType: VKeyboardType.desktop,
                      textInputAction: TextInputAction.newline,
                      maxLines: 4,
                      minLines: 3,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Click keyboard keys below or type with physical keyboard (Ctrl+A, Ctrl+C, Tab, Arrows, Numpad)...',
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF0B0E14)
                            : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark
                                ? const Color(0xFF23293A)
                                : const Color(0xFFCBD5E1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'OSK Engine Active',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Ctrl + S (Save)  •  Ctrl + P (Print)  •  Win + V (Clipboard)',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Edge-to-Edge Full-Width Responsive Desktop Virtual Keyboard
        DesktopFullKeyboard(
          controller: controller,
          themeData: desktopTheme,
          showFunctionRow: _desktopShowFnRow,
          maxKeyboardHeightRatio: 0.44,
          onKeyPressed: (char) {
            if (!_desktopFocusNode.hasFocus) {
              _desktopFocusNode.requestFocus();
              if (controller?.session == null) {
                final text = _desktopController.text;
                _desktopController.text = '$text$char';
                _desktopController.selection = TextSelection.collapsed(
                    offset: _desktopController.text.length);
              }
            }
            setState(() => _desktopLastEvent =
                char == ' ' ? 'Spacebar' : 'Key: $char');
          },
          onSpecialKeyPressed: (action) {
            setState(() => _desktopLastEvent = 'Special: ${action.name}');
          },
          onShortcutTriggered: (shortcut) {
            setState(() => _desktopLastEvent = 'Shortcut: $shortcut');
          },
        ),
      ],
    );
  }

  Widget _buildExamplesTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Pre-built Scenarios & Examples',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Common production use cases powered by flutter_v_keyboard.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        const SizedBox(height: 20),
        Card(
          color: isDark ? const Color(0xFF181F2E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDark ? const Color(0xFF263248) : const Color(0xFFE2E8F0),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.payment_rounded, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Scenario 1: Checkout Form Flow',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                VTextField(
                  keyboardType: VKeyboardType.standard,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                VTextField(
                  keyboardType: VKeyboardType.number,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Card Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: VTextField(
                        keyboardType: VKeyboardType.number,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'MM/YY',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: VTextField(
                        keyboardType: VKeyboardType.pin,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'CVV',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
