import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide ModifierKey;
import 'package:v_keyboard/v_keyboard.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Keyboard Demo',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      // One scope wraps the whole app: every VTextField below it shares
      // the keyboard, focus traversal and push-up behaviour. VKeyboardShortcuts
      // adds desktop shortcuts + media/meta callbacks for the whole subtree.
      builder: (context, child) => VKeyboardScope(
        child: VKeyboardShortcuts(
          shortcuts: {
            LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
                () => debugPrint('Ctrl+S → save'),
            LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyP):
                () => debugPrint('Ctrl+P → print'),
          },
          onMedia: (intent) => debugPrint('media: $intent'),
          onMetaKey: () => debugPrint('Win key'),
          child: child!,
        ),
      ),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final _standard = TextEditingController();
  final _email = TextEditingController();
  final _url = TextEditingController();
  final _number = TextEditingController();
  final _decimal = TextEditingController();
  final _phone = TextEditingController();
  final _pin = TextEditingController();
  final _password = TextEditingController();
  final _multiline = TextEditingController();
  final _custom = TextEditingController();
  final _desktop = TextEditingController();

  String _lastEvent = '—';

  @override
  void dispose() {
    for (final c in [
      _standard, _email, _url, _number, _decimal,
      _phone, _pin, _password, _multiline, _custom, _desktop,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // A completely custom layout built without touching package source.
  KeyboardLayout get _greekLayout => KeyboardLayout(
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
              KeyData.space(),
              KeyData.enter(flex: 2),
            ],
          ],
        },
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Native-like: content resizes when the keyboard appears.
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Virtual Keyboard')),
      body: FocusTraversalGroup(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _label('Last action: $_lastEvent'),
            _field('Standard (next)', _standard,
                type: VKeyboardType.standard,
                action: TextInputAction.next),
            _field('Email (next)', _email,
                type: VKeyboardType.email,
                action: TextInputAction.next),
            _field('URL (go)', _url,
                type: VKeyboardType.url, action: TextInputAction.go),
            _field('Number', _number, type: VKeyboardType.number),
            _field('Decimal', _decimal, type: VKeyboardType.decimal),
            _field('Phone', _phone, type: VKeyboardType.phone),
            _field('PIN', _pin,
                type: VKeyboardType.pin, obscure: true),
            _field('Password', _password,
                type: VKeyboardType.password, obscure: true),
            _multilineField(),
            _field('Custom Greek layout', _custom,
                type: VKeyboardType.custom, custom: _greekLayout),
            const Divider(height: 32),
            Text('Desktop keyboard (Windows OSK style)',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            const Text(
              'Full physical layout: function row, modifiers, navigation, '
              'numeric keypad and media keys. Resize the window to see sections '
              'collapse. Try Shift/Ctrl + keys, arrows, Ctrl+A/C/V, Ctrl+S.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            _desktopField(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text, style: Theme.of(context).textTheme.labelLarge),
      );

  Widget _field(
    String label,
    TextEditingController controller, {
    required VKeyboardType type,
    TextInputAction action = TextInputAction.done,
    bool obscure = false,
    KeyboardLayout? custom,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: VTextField(
        controller: controller,
        keyboardType: type,
        textInputAction: action,
        obscureText: obscure,
        customLayout: custom,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (v) => setState(() => _lastEvent = 'submitted "$v"'),
        onAction: (a) => setState(() => _lastEvent = 'action $a'),
      ),
    );
  }

  Widget _desktopField() {
    return VTextField(
      controller: _desktop,
      keyboardType: VKeyboardType.desktop,
      textInputAction: TextInputAction.newline,
      maxLines: 4,
      minLines: 3,
      decoration: const InputDecoration(
        labelText: 'Desktop field',
        alignLabelWithHint: true,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _multilineField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: VTextField(
        controller: _multiline,
        keyboardType: VKeyboardType.multiline,
        textInputAction: TextInputAction.newline,
        maxLines: 4,
        minLines: 3,
        decoration: const InputDecoration(
          labelText: 'Multiline (Enter = newline)',
          alignLabelWithHint: true,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
