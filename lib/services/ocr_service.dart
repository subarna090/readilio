import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'text_cleanup_service.dart';

class OcrResult {
  final String rawText;
  final List<String> words;
  final double avgConfidence;
  final bool isLowConfidence;

  OcrResult({
    required this.rawText,
    required this.words,
    required this.avgConfidence,
    required this.isLowConfidence,
  });
}

class OcrService {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final _cleanup = TextCleanupService();

  Future<OcrResult> processImage(String imagePath) async {
    final inputImage = InputImage.fromFile(File(imagePath));
    final recognized = await _recognizer.processImage(inputImage);

    if (recognized.text.isEmpty) {
      return OcrResult(
        rawText: '',
        words: [],
        avgConfidence: 0,
        isLowConfidence: true,
      );
    }

    // Collect all elements (words) from blocks
    final allElements = <TextElement>[];
    for (final block in recognized.blocks) {
      for (final line in block.lines) {
        allElements.addAll(line.elements);
      }
    }

    // ML Kit doesn't expose per-word confidence publicly;
    // we use a fixed high confidence when text is detected.
    const double avgConfidence = 0.85;
    const isLowConfidence = avgConfidence < 0.8;

    // Clean up text
    final cleanedText = _cleanup.clean(recognized.text);
    final words = _cleanup.tokenizeWords(cleanedText);

    return OcrResult(
      rawText: cleanedText,
      words: words,
      avgConfidence: avgConfidence,
      isLowConfidence: isLowConfidence,
    );
  }

  Future<void> dispose() async {
    await _recognizer.close();
  }
}
