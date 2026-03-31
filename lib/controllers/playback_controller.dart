import 'package:get/get.dart';
import '../models/story_session.dart';
import '../services/tts_service.dart';

class PlaybackController extends GetxController {
  final TtsService _tts = Get.find();

  late StorySession session;

  final currentPageIndex = 0.obs;
  final currentWordIndex = (-1).obs;
  final isPlaying = false.obs;
  final isDone = false.obs;
  final playbackRate = 0.75.obs;

  // Flattened word list across all pages with page boundaries
  final List<_PageBoundary> _pageBoundaries = [];
  List<String> _allWords = [];

  void init(StorySession s) {
    session = s;
    _buildWordList();
  }

  void _buildWordList() {
    _allWords = [];
    _pageBoundaries.clear();
    int offset = 0;
    for (final page in session.pages) {
      _pageBoundaries.add(_PageBoundary(
        pageIndex: page.pageNumber - 1,
        startWord: offset,
        endWord: offset + page.words.length - 1,
      ));
      _allWords.addAll(page.words);
      offset += page.words.length;
    }
  }

  List<String> get currentPageWords {
    final page = session.pages[currentPageIndex.value];
    return page.words;
  }

  int get localWordIndex {
    final boundary = _pageBoundaries[currentPageIndex.value];
    final local = currentWordIndex.value - boundary.startWord;
    return local;
  }

  Future<void> play() async {
    if (_allWords.isEmpty) return;

    isPlaying.value = true;
    isDone.value = false;

    final startOffset = _pageBoundaries[currentPageIndex.value].startWord;
    final wordsFromHere = _allWords.sublist(startOffset);

    await _tts.speakWithWordSync(
      words: wordsFromHere,
      onWord: (idx) {
        final globalIdx = startOffset + idx;
        currentWordIndex.value = globalIdx;
        _updatePageForWord(globalIdx);
      },
      onComplete: () {
        isPlaying.value = false;
        isDone.value = true;
        currentWordIndex.value = -1;
      },
    );
  }

  void _updatePageForWord(int globalIdx) {
    for (final boundary in _pageBoundaries) {
      if (globalIdx >= boundary.startWord && globalIdx <= boundary.endWord) {
        if (currentPageIndex.value != boundary.pageIndex) {
          currentPageIndex.value = boundary.pageIndex;
        }
        return;
      }
    }
  }

  Future<void> pause() async {
    await _tts.pause();
    isPlaying.value = false;
  }

  Future<void> togglePlayPause() async {
    if (isPlaying.value) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> setRate(double rate) async {
    playbackRate.value = rate;
    await _tts.setRate(rate);
  }

  Future<void> goToPage(int index) async {
    await _tts.stop();
    isPlaying.value = false;
    currentPageIndex.value = index.clamp(0, session.pages.length - 1);
    currentWordIndex.value = -1;
  }

  Future<void> replay() async {
    await _tts.stop();
    currentWordIndex.value = -1;
    isPlaying.value = false;
    await play();
  }

  @override
  void onClose() {
    _tts.stop();
    super.onClose();
  }
}

class _PageBoundary {
  final int pageIndex;
  final int startWord;
  final int endWord;
  _PageBoundary({
    required this.pageIndex,
    required this.startWord,
    required this.endWord,
  });
}
