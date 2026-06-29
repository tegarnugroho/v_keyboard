import 'package:flutter/material.dart';
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
      // One scope wraps the whole app: every VirtualTextField below it shares
      // the keyboard, focus traversal and push-up behaviour.
      builder: (context, child) => VirtualKeyboardScope(child: child!),
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

  String _lastEvent = '—';

  @override
  void dispose() {
    for (final c in [
      _standard, _email, _url, _number, _decimal,
      _phone, _pin, _password, _multiline, _custom,
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
                type: VirtualKeyboardType.standard,
                action: TextInputAction.next),
            _field('Email (next)', _email,
                type: VirtualKeyboardType.email,
                action: TextInputAction.next),
            _field('URL (go)', _url,
                type: VirtualKeyboardType.url, action: TextInputAction.go),
            _field('Number', _number, type: VirtualKeyboardType.number),
            _field('Decimal', _decimal, type: VirtualKeyboardType.decimal),
            _field('Phone', _phone, type: VirtualKeyboardType.phone),
            _field('PIN', _pin,
                type: VirtualKeyboardType.pin, obscure: true),
            _field('Password', _password,
                type: VirtualKeyboardType.password, obscure: true),
            _multilineField(),
            _field('Custom Greek layout', _custom,
                type: VirtualKeyboardType.custom, custom: _greekLayout),
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
    required VirtualKeyboardType type,
    TextInputAction action = TextInputAction.done,
    bool obscure = false,
    KeyboardLayout? custom,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: VirtualTextField(
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

  Widget _multilineField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: VirtualTextField(
        controller: _multiline,
        keyboardType: VirtualKeyboardType.multiline,
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
