/// Interface for language Input Method Engines (IME) that provide
/// candidate suggestions based on a composing text buffer.
abstract class ImeEngine {
  /// The unique locale identifier for this engine (e.g. 'zh_CN', 'zh_TW', 'ja_JP').
  String get localeId;

  /// Returns a list of candidate suggestions for the given [composingText],
  /// limited to [maxCandidates].
  List<String> getCandidates(String composingText, {int maxCandidates = 8});

  /// Whether [char] is a valid input key for this IME engine.
  bool isValidInput(String char);

  /// Normalizes incoming character input before appending to composing buffer.
  String normalizeInput(String char) => char;

  /// Whether pressing the space key should commit the first candidate.
  bool get commitOnSpace => true;
}
