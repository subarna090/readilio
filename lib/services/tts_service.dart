import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

typedef WordCallback = void Function(int wordIndex);
typedef CompletionCallback = void Function();

class TtsService {
  final FlutterTts _tts = FlutterTts();
  double _rate = 0.75;

  // Exposed observables for controllers
  final currentWordIndex = (-1).obs;
  final isPlaying = false.obs;
  final isDone = false.obs;

  Future<void> init() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(_rate);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);

    _tts.setStartHandler(() {
      isPlaying.value = true;
      isDone.value = false;
    });

    _tts.setCompletionHandler(() {
      isPlaying.value = false;
      isDone.value = true;
    });

    _tts.setCancelHandler(() {
      isPlaying.value = false;
    });

    _tts.setProgressHandler((text, start, end, word) {
      // This fires on each word boundary
      // We use it to highlight the current word
    });
  }

  Future<void> speakWithWordSync({
    required List<String> words,
    required WordCallback onWord,
    required CompletionCallback onComplete,
  }) async {
    if (words.isEmpty) return;
    isDone.value = false;

    final text = words.join(' ');

    _tts.setProgressHandler((utterance, start, end, word) {
      // Find word index by matching start offset
      int idx = _findWordIndex(words, start);
      currentWordIndex.value = idx;
      onWord(idx);
    });

    _tts.setCompletionHandler(() {
      isPlaying.value = false;
      isDone.value = true;
      currentWordIndex.value = -1;
      onComplete();
    });

    await _tts.speak(text);
  }

  int _findWordIndex(List<String> words, int charOffset) {
    int pos = 0;
    for (int i = 0; i < words.length; i++) {
      if (charOffset >= pos && charOffset < pos + words[i].length) {
        return i;
      }
      pos += words[i].length + 1; // +1 for space
    }
    return words.length - 1;
  }

  Future<void> pause() async {
    await _tts.pause();
    isPlaying.value = false;
  }

  Future<void> resume() async {
    // flutter_tts doesn't support true resume; restart from current word
    isPlaying.value = true;
  }

  Future<void> stop() async {
    await _tts.stop();
    isPlaying.value = false;
    currentWordIndex.value = -1;
  }

  Future<void> setRate(double rate) async {
    _rate = rate.clamp(0.75, 1.5);
    await _tts.setSpeechRate(_rate);
  }

  double get rate => _rate;

  Future<void> dispose() async {
    await _tts.stop();
  }
}
