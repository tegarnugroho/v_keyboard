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
  String _selectedLayoutName = 'QWERTY';
  bool _showClipboardInPreview = true;

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

  // Desktop tab controller
  final TextEditingController _desktopController = TextEditingController();

  // Custom layout definition (Greek alphabet)
  static final KeyboardLayout _greekLayout = KeyboardLayout(
    id: 'greek',
    initialPage: 'main',
    pages: {
      'main': [
        'αβγδεζηθ'.split('').map((c) => KeyData.char(c)).toList(),
        'ικλμνξοπ'.split('').map((c) => KeyData.char(c)).toList(),
        [
          KeyData.shift(flex: 1.5),
          ...'ρστυφχψ'.split('').map((c) => KeyData.char(c)),
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
          KeyData.switchTo('main', label: 'αβγ', flex: 2),
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
      _selectedLayoutName = 'Desktop';
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
    super.dispose();
  }

  void _onSelectKeyboardType(VKeyboardType type) {
    setState(() {
      _selectedType = type;
      switch (type) {
        case VKeyboardType.standard:
          _selectedLayoutName = 'QWERTY';
        case VKeyboardType.email:
          _selectedLayoutName = 'Email';
        case VKeyboardType.number:
          _selectedLayoutName = 'Number';
        case VKeyboardType.decimal:
          _selectedLayoutName = 'Decimal';
        case VKeyboardType.url:
          _selectedLayoutName = 'URL';
        case VKeyboardType.phone:
          _selectedLayoutName = 'Phone';
        case VKeyboardType.pin:
          _selectedLayoutName = 'PIN';
        case VKeyboardType.password:
          _selectedLayoutName = 'Password';
        case VKeyboardType.custom:
          _selectedLayoutName = 'Greek';
        case VKeyboardType.desktop:
          _selectedLayoutName = 'Desktop';
        default:
          _selectedLayoutName = 'QWERTY';
      }
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
        _playgroundController.text = 'αβγδε';
        _playgroundFocusNode.requestFocus();
        break;
      case 3: // Desktop Support
        setState(() {
          _currentTab = _ActiveTab.desktop;
          _selectedType = VKeyboardType.desktop;
          _selectedLayoutName = 'Desktop';
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Column 1: Left Sidebar
                    SizedBox(
                      width: 260,
                      child: _buildSidebar(isDark, cardBg, borderColor),
                    ),
                    const SizedBox(width: 16),
                    // Column 2: Center Content Panel
                    Expanded(
                      flex: _currentTab == _ActiveTab.desktop ? 1 : 5,
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
                    if (_currentTab != _ActiveTab.desktop) ...[
                      const SizedBox(width: 16),
                      // Column 3: Right Keyboard Preview Panel
                      Expanded(
                        flex: 6,
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
                ),
              ),
            ],
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
                          _selectedLayoutName = 'QWERTY';
                        } else if (tab == _ActiveTab.desktop) {
                          _selectedType = VKeyboardType.desktop;
                          _selectedLayoutName = 'Desktop';
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
                _selectedType == VKeyboardType.custom ? _greekLayout : null,
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
            childAspectRatio: isNarrow ? 3.8 : 2.5,
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 3),
                      Text(
                        item.$2,
                        style: TextStyle(
                          fontSize: 11,
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
                  child: DropdownButton<String>(
                    value: _selectedLayoutName,
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
                          value: 'QWERTY', child: Text('QWERTY')),
                      DropdownMenuItem(value: 'Email', child: Text('Email')),
                      DropdownMenuItem(
                          value: 'Number', child: Text('Number')),
                      DropdownMenuItem(value: 'Phone', child: Text('Phone')),
                      DropdownMenuItem(value: 'PIN', child: Text('PIN')),
                      DropdownMenuItem(value: 'Greek', child: Text('Greek')),
                      DropdownMenuItem(
                          value: 'Desktop', child: Text('Desktop')),
                    ],
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() {
                        _selectedLayoutName = val;
                        if (val == 'QWERTY') {
                          _selectedType = VKeyboardType.standard;
                        } else if (val == 'Email') {
                          _selectedType = VKeyboardType.email;
                        } else if (val == 'Number') {
                          _selectedType = VKeyboardType.number;
                        } else if (val == 'Phone') {
                          _selectedType = VKeyboardType.phone;
                        } else if (val == 'PIN') {
                          _selectedType = VKeyboardType.pin;
                        } else if (val == 'Greek') {
                          _selectedType = VKeyboardType.custom;
                        } else if (val == 'Desktop') {
                          _selectedType = VKeyboardType.desktop;
                        }
                      });
                      _playgroundFocusNode.requestFocus();
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
              : AnimatedBuilder(
                  animation: controller,
                  builder: (context, _) {
                    final isClipboard = _showClipboardInPreview ||
                        controller.currentPage == 'clipboard';
                    final isEmoji = controller.currentPage == 'emoji';

                    return TapRegion(
                      groupId: scope?.tapGroup ?? Object(),
                      child: Stack(
                        children: [
                          // Virtual Keyboard
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: _buildEmbeddedKeyboardView(
                                controller,
                                theme,
                                isDark,
                              ),
                            ),
                          ),

                          // Floating Clipboard Panel (shown when clipboard icon is active)
                          if (isClipboard)
                            Positioned(
                              left: 20,
                              right: 20,
                              bottom: 250,
                              child: _buildFloatingClipboardPanel(
                                controller,
                                theme,
                                isDark,
                              ),
                            ),

                          // Floating Emoji Panel (shown when emoji icon is active)
                          if (isEmoji)
                            Positioned(
                              left: 20,
                              right: 20,
                              bottom: 250,
                              height: 220,
                              child: Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(12),
                                color: isDark
                                    ? const Color(0xFF181D2A)
                                    : Colors.white,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: EmojiPanel(
                                    controller: controller,
                                    theme: theme,
                                    height: 220,
                                    maxWidth: 600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
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
    bool isDark,
  ) {
    if (_selectedType == VKeyboardType.desktop) {
      final desktopRows = DesktopLayouts.rows(960);
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 960,
          child: KeyboardView(
            controller: controller,
            theme: theme,
            metrics: const KeyboardMetrics(
              height: 230,
              maxWidth: 960,
              horizontalPadding: 8,
              rowSpacing: 5,
              formFactor: DeviceFormFactor.desktop,
              isLandscape: true,
            ),
            rows: desktopRows,
            bottomSafeArea: 0,
          ),
        ),
      );
    }

    // Resolve rows based on selected type/layout
    final layout = BuiltinLayouts.resolve(
      _selectedType,
      custom: _selectedType == VKeyboardType.custom ? _greekLayout : null,
    );
    final page = (controller.currentPage.isNotEmpty &&
            controller.currentPage != 'clipboard' &&
            controller.currentPage != 'emoji')
        ? controller.currentPage
        : layout.initialPage;
    final rows = layout.rowsFor(page);

    const metrics = KeyboardMetrics(
      height: 230,
      maxWidth: 640,
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

  Widget _buildFloatingClipboardPanel(
    VKeyboardController controller,
    VKeyboardTheme theme,
    bool isDark,
  ) {
    final history = controller.clipboardHistory;
    final items = history.items;
    final activeColor = widget.accentColor.color;

    return Material(
      elevation: 12,
      borderRadius: BorderRadius.circular(12),
      color: isDark ? const Color(0xFF131722) : Colors.white,
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF283247) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Clipboard Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.content_paste_rounded,
                    size: 16,
                    color: activeColor,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Clipboard',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 16),
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      setState(() => _showClipboardInPreview = false);
                      controller.closeClipboardHistory();
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF192030)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF263045)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      size: 16,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Search clipboard...',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Snippets List
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        'Clipboard history is empty',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isUrl = item.text.startsWith('http://') ||
                            item.text.startsWith('https://');

                        return InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            controller.pasteClipboardItem(item);
                            _playgroundFocusNode.requestFocus();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF181F2E)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF242F44)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: activeColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    isUrl
                                        ? Icons.link_rounded
                                        : Icons.description_outlined,
                                    size: 16,
                                    color: activeColor,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.text,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.isPinned ? 'Just now' : 'Recent',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark
                                              ? Colors.white38
                                              : Colors.black38,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    item.isPinned
                                        ? Icons.push_pin_rounded
                                        : Icons.push_pin_outlined,
                                    size: 15,
                                    color: item.isPinned
                                        ? activeColor
                                        : (isDark
                                            ? Colors.white38
                                            : Colors.black38),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () =>
                                      history.togglePin(item.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
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
      ],
    );
  }

  Widget _buildDesktopTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Full Desktop Keyboard (OSK Style)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Includes function row (F1-F12), navigation cluster, numpad, and modifier handling.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        const SizedBox(height: 20),
        VTextField(
          controller: _desktopController,
          keyboardType: VKeyboardType.desktop,
          textInputAction: TextInputAction.newline,
          maxLines: 4,
          minLines: 3,
          decoration: InputDecoration(
            hintText: 'Type with desktop shortcuts (Ctrl+A, Ctrl+C, Ctrl+V, Shift+arrows)...',
            filled: true,
            fillColor:
                isDark ? const Color(0xFF11141E) : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Desktop Keyboard Layout (Interactive)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Builder(
          builder: (context) {
            final scope = VKeyboardScope.maybeOf(context);
            final controller = scope?.controller;
            final theme = scope?.theme ??
                (isDark ? VKeyboardTheme.dark() : VKeyboardTheme.light());
            if (controller == null) return const SizedBox.shrink();

            return LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final layoutWidth =
                    availableWidth < 1000 ? 1000.0 : availableWidth;
                final rows = DesktopLayouts.rows(layoutWidth);
                final rowCount = rows.length;
                final keyboardHeight =
                    (rowCount * 46.0) + ((rowCount - 1) * 6.0) + 24.0;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF11141E)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF263248)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
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
                          rowSpacing: 6,
                          formFactor: DeviceFormFactor.desktop,
                          isLandscape: true,
                        ),
                        rows: rows,
                        bottomSafeArea: 0,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'Supported Shortcuts',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildShortcutTile('Ctrl + S', 'Quick save callback', isDark),
        _buildShortcutTile('Ctrl + P', 'Print document callback', isDark),
        _buildShortcutTile('Win + V / Ctrl+Shift+V', 'Open Clipboard History', isDark),
      ],
    );
  }

  Widget _buildShortcutTile(String keyCombo, String description, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF222B3D) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              keyCombo,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
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
                    Text(
                      'Scenario 1: Checkout Form Flow',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
