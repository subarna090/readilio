/// Cleans common OCR artefacts from raw extracted text.
class TextCleanupService {
  static final _doubleSpace = RegExp(r'  +');
  static final _pipeToL = RegExp(r'\|');
  static final _multiNewline = RegExp(r'\n{3,}');
  // Hyphenated line-break: word-\nword → wordword
  static final _hyphenBreak = RegExp(r'-\n(\w)');
  // Stutter: "the the" or "a a"
  static final _stutter = RegExp(r'\b(\w{1,4})\s+\1\b', caseSensitive: false);

  String clean(String raw) {
    String text = raw;

    // Fix pipe → l (common OCR artefact: "l|'ve" → "l've")
    text = text.replaceAll(_pipeToL, 'l');

    // Normalise curly quotes
    text = text.replaceAll(RegExp('[\u201c\u201d]'), '"');
    text = text.replaceAll(RegExp('[\u2018\u2019]'), "'");

    // Fix hyphenated line breaks
    text = text.replaceAllMapped(_hyphenBreak, (m) => m.group(1)!);

    // Collapse multiple blank lines
    text = text.replaceAll(_multiNewline, '\n\n');

    // Collapse multiple spaces
    text = text.replaceAll(_doubleSpace, ' ');

    // Remove stutter duplicates (simple heuristic)
    text = text.replaceAllMapped(
        _stutter, (m) => m.group(1)!);

    return text.trim();
  }

  /// Splits cleaned text into individual word tokens (strips punctuation).
  List<String> tokenizeWords(String text) {
    return text
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
  }

  /// Splits text into sentences for TTS chunking.
  List<String> splitSentences(String text) {
    final sentences = text
        .split(RegExp(r'(?<=[.!?])\s+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();
    return sentences.isEmpty ? [text] : sentences;
  }
}
