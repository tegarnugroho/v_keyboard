// Generates the README / pub.dev showcase images from the *real* package
// widgets (KeyboardView + layouts + theme), composed with premium framing.
//
// Run on a real engine so fonts/icons render:
//   cd example
//   flutter test integration_test/showcase_test.dart -d windows
//
// PNGs are written to ../assets/showcase/.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:v_keyboard/v_keyboard.dart';

const _accent = Color(0xFF6366F1);
const _outDir = '../assets/showcase';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('generate showcase images', (tester) async {
    Directory(_outDir).createSync(recursive: true);

    for (final scene in _scenes()) {
      await _shoot(tester, scene);
    }
  });
}

// ---------------------------------------------------------------------------
// Capture
// ---------------------------------------------------------------------------

class _Scene {
  _Scene(this.name, this.size, this.build, {this.dpr = 2.5});
  final String name;
  final Size size;
  final Widget Function() build;
  final double dpr;
}

Future<void> _shoot(WidgetTester tester, _Scene scene) async {
  final key = GlobalKey();
  tester.view.physicalSize = scene.size * scene.dpr;
  tester.view.devicePixelRatio = scene.dpr;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: MediaQuery(
        data: MediaQueryData(size: scene.size, devicePixelRatio: scene.dpr),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: scene.build(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: scene.dpr);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File('$_outDir/${scene.name}.png')
      .writeAsBytesSync(bytes!.buffer.asUint8List());
  // ignore: avoid_print
  print('wrote $_outDir/${scene.name}.png');
}

// ---------------------------------------------------------------------------
// Building blocks
// ---------------------------------------------------------------------------

VKeyboardTheme _theme(bool dark) => VKeyboardTheme.fromTheme(ThemeData(
      colorSchemeSeed: _accent,
      brightness: dark ? Brightness.dark : Brightness.light,
      useMaterial3: true,
    ));

LinearGradient _bg(bool dark) => LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: dark
          ? const [Color(0xFF0C0C12), Color(0xFF16161F)]
          : const [Color(0xFFEEF2FF), Color(0xFFF7FAFF)],
    );

/// A static keyboard rendered from the real [KeyboardView].
Widget _keyboard({
  required List<List<KeyData>> rows,
  required bool dark,
  required double height,
  double maxWidth = double.infinity,
  void Function(VKeyboardController)? state,
}) {
  final controller = VKeyboardController();
  state?.call(controller);
  final metrics = KeyboardMetrics(
    height: height,
    maxWidth: maxWidth,
    horizontalPadding: maxWidth.isFinite ? 8 : 5,
    rowSpacing: 6,
    formFactor:
        maxWidth.isFinite ? DeviceFormFactor.desktop : DeviceFormFactor.phone,
    isLandscape: false,
  );
  return KeyboardView(
    controller: controller,
    theme: _theme(dark),
    metrics: metrics,
    rows: rows,
    bottomSafeArea: 0,
  );
}

/// A faux text field (premium styled) showing [text] with a blinking-style caret.
Widget _field(
  String text, {
  required bool dark,
  String? label,
  bool obscure = false,
  bool focused = true,
  TextSelection? selection,
  bool multiline = false,
}) {
  final display = obscure ? '•' * text.length : text;
  final onSurface = dark ? Colors.white : const Color(0xFF1A1A22);
  final fieldColor = dark ? const Color(0xFF1B1B23) : Colors.white;

  Widget content;
  if (selection != null && !selection.isCollapsed && !obscure) {
    final a = selection.start, b = selection.end;
    content = RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 17, color: onSurface),
        children: [
          TextSpan(text: text.substring(0, a)),
          TextSpan(
            text: text.substring(a, b),
            style: TextStyle(background: Paint()..color = _accent.withValues(alpha: 0.35)),
          ),
          TextSpan(text: text.substring(b)),
        ],
      ),
    );
  } else {
    content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            display.isEmpty ? '' : display,
            maxLines: multiline ? 4 : 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 17, color: onSurface, height: 1.4),
          ),
        ),
        if (focused)
          Container(
            width: 2,
            height: 22,
            margin: const EdgeInsets.only(left: 1),
            color: _accent,
          ),
      ],
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (label != null)
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: onSurface.withValues(alpha: 0.6))),
        ),
      Container(
        height: multiline ? 96 : 52,
        alignment: multiline ? Alignment.topLeft : Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: fieldColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: focused ? _accent : onSurface.withValues(alpha: 0.12),
              width: focused ? 2 : 1),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.4 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6)),
          ],
        ),
        child: content,
      ),
    ],
  );
}

/// A phone-style screen: gradient bg, fields at the top, keyboard pinned bottom.
Widget _phoneScreen({
  required bool dark,
  required List<Widget> fields,
  required Widget keyboard,
}) {
  return DecoratedBox(
    decoration: BoxDecoration(gradient: _bg(dark)),
    child: Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final f in fields) ...[f, const SizedBox(height: 16)],
              ],
            ),
          ),
        ),
        keyboard,
      ],
    ),
  );
}

/// Rounded device frame with soft shadow.
Widget _deviceFrame(Widget child,
    {double radius = 38, double bezel = 10, Color? bezelColor}) {
  return Container(
    decoration: BoxDecoration(
      color: bezelColor ?? const Color(0xFF0B0B10),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 60,
            spreadRadius: 2,
            offset: const Offset(0, 30)),
      ],
    ),
    padding: EdgeInsets.all(bezel),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(radius - bezel),
      child: child,
    ),
  );
}

// ---------------------------------------------------------------------------
// Layout data (from the real package)
// ---------------------------------------------------------------------------

List<List<KeyData>> get _abc => BuiltinLayouts.qwerty.rowsFor('abc');
List<List<KeyData>> get _sym => BuiltinLayouts.qwerty.rowsFor('123');
List<List<KeyData>> _pin() =>
    BuiltinLayouts.resolve(VKeyboardType.pin, numericAction: true).rowsFor('num');
List<List<KeyData>> _multi() =>
    BuiltinLayouts.resolve(VKeyboardType.multiline).rowsFor('abc');
List<List<KeyData>> _desktop(double w) => DesktopLayouts.rows(w);

void _shift(VKeyboardController c) => c.modifiers.toggleModifier(ModifierKey.shift);
void _caps(VKeyboardController c) => c.modifiers.toggleLock(LockKey.capsLock);

// ---------------------------------------------------------------------------
// Scenes
// ---------------------------------------------------------------------------

const _phone = Size(390, 844);
const _phoneLand = Size(844, 390);
const _tablet = Size(820, 1180);
const _wide = Size(1600, 900);

List<_Scene> _scenes() => [
      // ---- Hero ----
      _Scene('hero', _wide, () => _hero(), dpr: 2),

      // ---- Mobile ----
      _Scene('mobile_standard', _phone, () => _mobileStandard(false)),
      _Scene('mobile_number', _phone, () => _mobileNumber()),
      _Scene('mobile_password', _phone, () => _mobilePassword()),
      _Scene('mobile_multiline', _phone, () => _mobileMultiline()),

      // ---- Desktop ----
      _Scene('desktop_keyboard', const Size(1280, 760), () => _desktopScene(),
          dpr: 2),

      // ---- Themes ----
      _Scene('light_theme', _phone, () => _mobileStandard(false)),
      _Scene('dark_theme', _phone, () => _mobileStandard(true)),

      // ---- Responsive ----
      _Scene('responsive', _wide, () => _responsive(), dpr: 2),

      // ---- Features ----
      _Scene('feature_shift', _phone, () => _feature('Shift', _abc, _shift)),
      _Scene('feature_capslock', _phone, () => _feature('Caps Lock', _abc, _caps)),
      _Scene('feature_symbols', _phone, () => _feature('Symbols', _sym, null)),
      _Scene('feature_selection', _phone, () => _featureSelection()),
      _Scene('feature_focus', _phone, () => _featureFocus()),
    ];

Widget _mobileStandard(bool dark) => _phoneScreen(
      dark: dark,
      fields: [
        _field('Hello world', dark: dark, label: 'Message'),
      ],
      keyboard: _keyboard(rows: _abc, dark: dark, height: 290, state: _shift),
    );

Widget _mobileNumber() => _phoneScreen(
      dark: false,
      fields: [_field('1234', dark: false, label: 'PIN', obscure: true)],
      keyboard: _keyboard(rows: _pin(), dark: false, height: 300),
    );

Widget _mobilePassword() => _phoneScreen(
      dark: true,
      fields: [_field('s3cr3tPass', dark: true, label: 'Password', obscure: true)],
      keyboard: _keyboard(rows: _abc, dark: true, height: 290),
    );

Widget _mobileMultiline() => _phoneScreen(
      dark: false,
      fields: [
        _field('Dear team,\nShipping the new release', dark: false,
            label: 'Note', multiline: true),
      ],
      keyboard: _keyboard(rows: _multi(), dark: false, height: 290),
    );

Widget _desktopScene() {
  const w = 1180.0;
  final rows = _desktop(w);
  final rowH = (w / 24).clamp(34.0, 58.0);
  final h = rows.length * rowH + 6 * (rows.length - 1) + 16;
  return DecoratedBox(
    decoration: BoxDecoration(gradient: _bg(false)),
    child: Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40, 36, 40, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('v_keyboard · Desktop',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A22))),
                const SizedBox(height: 20),
                _field('The quick brown fox jumps over the lazy dog',
                    dark: false, label: 'Editor'),
              ],
            ),
          ),
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: w),
            child: _keyboard(rows: rows, dark: false, height: h, maxWidth: w),
          ),
        ),
      ],
    ),
  );
}

Widget _feature(String title, List<List<KeyData>> rows,
        void Function(VKeyboardController)? state) =>
    _phoneScreen(
      dark: false,
      fields: [
        _badge(title),
        const SizedBox(height: 4),
        _field('Type here', dark: false, label: title),
      ],
      keyboard: _keyboard(rows: rows, dark: false, height: 290, state: state),
    );

Widget _featureSelection() => _phoneScreen(
      dark: false,
      fields: [
        _badge('Text selection'),
        const SizedBox(height: 4),
        _field('Select this text', dark: false, label: 'Selection',
            selection: const TextSelection(baseOffset: 7, extentOffset: 11)),
      ],
      keyboard: _keyboard(rows: _abc, dark: false, height: 290),
    );

Widget _featureFocus() => _phoneScreen(
      dark: false,
      fields: [
        _badge('Focus · TextInputAction.next'),
        const SizedBox(height: 4),
        _field('john', dark: false, label: 'First name', focused: false),
        _field('', dark: false, label: 'Last name', focused: true),
      ],
      keyboard: _keyboard(rows: _abc, dark: false, height: 270),
    );

Widget _badge(String text) => Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _accent.withValues(alpha: 0.4)),
        ),
        child: Text(text,
            style: const TextStyle(
                color: _accent, fontWeight: FontWeight.w700, fontSize: 13)),
      ),
    );

Widget _hero() => DecoratedBox(
      decoration: BoxDecoration(gradient: _bg(false)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 70),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _badge('Flutter · Material 3'),
                  const SizedBox(height: 24),
                  const Text('v_keyboard',
                      style: TextStyle(
                          fontSize: 76,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -2,
                          color: Color(0xFF15151E))),
                  const SizedBox(height: 16),
                  const Text(
                    'Native-feeling Virtual Keyboard for Flutter.\nMobile, desktop & web — one consistent API.',
                    style: TextStyle(
                        fontSize: 24,
                        height: 1.4,
                        color: Color(0xFF4A4A57),
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 28),
                  Row(children: [
                    _chip('10+ layouts'),
                    const SizedBox(width: 12),
                    _chip('Desktop OSK'),
                    const SizedBox(width: 12),
                    _chip('Shortcuts'),
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 50),
            Expanded(
              flex: 4,
              child: Center(
                child: SizedBox(
                  width: 330,
                  height: 690,
                  child: _deviceFrame(
                    _phoneScreen(
                      dark: false,
                      fields: [_field('Hello 👋', dark: false, label: 'Message')],
                      keyboard:
                          _keyboard(rows: _abc, dark: false, height: 250, state: _shift),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

Widget _chip(String text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: Color(0xFF15151E))),
    );

Widget _responsive() => DecoratedBox(
      decoration: BoxDecoration(gradient: _bg(false)),
      child: Padding(
        padding: const EdgeInsets.all(60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Responsive everywhere',
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF15151E))),
            const SizedBox(height: 8),
            const Text('Phone · Landscape · Tablet · Desktop',
                style: TextStyle(fontSize: 18, color: Color(0xFF4A4A57))),
            const SizedBox(height: 30),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _miniDevice(190, 410, _phone, _abc, 150),
                  const SizedBox(width: 28),
                  _miniDevice(410, 200, _phoneLand, _abc, 110),
                  const SizedBox(width: 28),
                  _miniDevice(300, 430, _tablet, _abc, 170),
                  const SizedBox(width: 28),
                  Expanded(child: _miniDesktop()),
                ],
              ),
            ),
          ],
        ),
      ),
    );

Widget _miniDevice(double w, double h, Size logical, List<List<KeyData>> rows,
    double kbH) {
  return _deviceFrame(
    radius: 26,
    bezel: 7,
    SizedBox(
      width: w,
      height: h,
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox(
          width: logical.width,
          height: logical.height,
          child: _phoneScreen(
            dark: false,
            fields: [_field('Aa', dark: false)],
            keyboard: _keyboard(rows: rows, dark: false, height: kbH),
          ),
        ),
      ),
    ),
  );
}

Widget _miniDesktop() => _deviceFrame(
      radius: 16,
      bezel: 8,
      bezelColor: const Color(0xFF1A1A22),
      AspectRatio(
        aspectRatio: 16 / 10,
        child: FittedBox(
          fit: BoxFit.fill,
          child: SizedBox(
            width: 1280,
            height: 760,
            child: _desktopScene(),
          ),
        ),
      ),
    );
