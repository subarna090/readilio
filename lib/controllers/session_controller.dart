import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/story_session.dart';
import '../services/storage_service.dart';
import '../services/ocr_service.dart';
import '../services/image_processing_service.dart';

enum ProcessingStatus { idle, capturing, processing, done, error }

class SessionController extends GetxController {
  final StorageService _storage = Get.find();
  final OcrService _ocr = OcrService();
  final ImageProcessingService _imgProcessor = ImageProcessingService();

  final status = ProcessingStatus.idle.obs;
  final capturedImagePaths = <String>[].obs;
  final processedPages = <StoryPage>[].obs;
  final currentProcessingPage = 0.obs;
  final errorMessage = ''.obs;
  final sessions = <StorySession>[].obs;

  String? _currentSessionId;

  @override
  void onInit() {
    super.onInit();
    loadSessions();
  }

  void loadSessions() {
    sessions.value = _storage.getAllSessions();
  }

  // --- Capture flow ---

  int get maxPhotos =>
      _storage.isPremium ? 20 : StorageService.freePhotosPerSession;

  bool get canAddMorePhotos => capturedImagePaths.length < maxPhotos;
  bool get isAtFreeLimit =>
      !_storage.isPremium &&
      capturedImagePaths.length >= StorageService.freePhotosPerSession;

  void startNewCapture() {
    _currentSessionId = const Uuid().v4();
    capturedImagePaths.clear();
    processedPages.clear();
    errorMessage.value = '';
    status.value = ProcessingStatus.capturing;
  }

  Future<void> addCapturedImage(String path) async {
    capturedImagePaths.add(path);
  }

  Future<void> retryLastCapture() async {
    if (capturedImagePaths.isNotEmpty) {
      capturedImagePaths.removeLast();
    }
  }

  // --- Processing ---

  Future<void> processAllPages() async {
    if (capturedImagePaths.isEmpty) return;

    status.value = ProcessingStatus.processing;
    processedPages.clear();

    final sessionId = _currentSessionId!;
    final imageDir = await _storage.getSessionImageDir(sessionId);

    for (int i = 0; i < capturedImagePaths.length; i++) {
      currentProcessingPage.value = i + 1;
      try {
        final processedPath = await _imgProcessor.preprocess(
          capturedImagePaths[i],
          imageDir,
        );
        final result = await _ocr.processImage(processedPath);

        processedPages.add(StoryPage(
          pageNumber: i + 1,
          imagePath: processedPath,
          rawText: result.rawText,
          words: result.words,
          avgConfidence: result.avgConfidence,
        ));
      } catch (e) {
        processedPages.add(StoryPage(
          pageNumber: i + 1,
          imagePath: capturedImagePaths[i],
          rawText: '',
          words: [],
          avgConfidence: 0,
        ));
      }
    }

    status.value = ProcessingStatus.done;
  }

  void updatePageText(int pageIndex, String newText) {
    if (pageIndex < 0 || pageIndex >= processedPages.length) return;
    final page = processedPages[pageIndex];
    final words = newText.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    processedPages[pageIndex] = StoryPage(
      pageNumber: page.pageNumber,
      imagePath: page.imagePath,
      rawText: newText,
      words: words,
      avgConfidence: page.avgConfidence,
      isEdited: true,
    );
    processedPages.refresh();
  }

  // --- Save session ---

  Future<StorySession> saveCurrentSession() async {
    final sessionId = _currentSessionId ?? const Uuid().v4();
    final title = 'Story ${sessions.length + 1}';
    final session = StorySession(
      id: sessionId,
      title: title,
      pages: processedPages.toList(),
      createdAt: DateTime.now(),
      lastOpenedAt: DateTime.now(),
      isPremium: _storage.isPremium,
    );
    await _storage.saveSession(session);
    await _storage.incrementSessionCount();
    loadSessions();
    return session;
  }

  Future<void> deleteSession(String id) async {
    await _storage.deleteSession(id);
    loadSessions();
  }

  Future<void> touchSession(String id) async {
    final session = _storage.getSession(id);
    if (session == null) return;
    session.lastOpenedAt = DateTime.now();
    await _storage.saveSession(session);
  }

  bool get canStartNewSession => _storage.canStartNewSession;
  bool get isPremium => _storage.isPremium;

  @override
  void onClose() {
    _ocr.dispose();
    super.onClose();
  }
}
