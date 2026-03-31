import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/story_session.dart';

class StorageService {
  static const _sessionsBox = 'sessions';
  static const _keyOnboardingDone = 'onboarding_done';
  static const _keySessionsThisWeek = 'sessions_this_week';
  static const _keyWeekStart = 'week_start';
  static const _keyIsPremium = 'is_premium';
  static const _sessionRetentionDays = 7;

  late Box<StorySession> _sessions;
  late SharedPreferences _prefs;

  Future<void> init() async {
    Hive.registerAdapter(StorySessionAdapter());
    Hive.registerAdapter(StoryPageAdapter());
    _sessions = await Hive.openBox<StorySession>(_sessionsBox);
    _prefs = await SharedPreferences.getInstance();
    _purgeExpiredSessions();
  }

  // --- Onboarding ---
  bool get onboardingDone => _prefs.getBool(_keyOnboardingDone) ?? false;
  Future<void> setOnboardingDone() =>
      _prefs.setBool(_keyOnboardingDone, true);

  // --- Premium status ---
  bool get isPremium => _prefs.getBool(_keyIsPremium) ?? false;
  Future<void> setPremium(bool value) =>
      _prefs.setBool(_keyIsPremium, value);

  // --- Free tier limits ---
  static const int freePhotosPerSession = 3;
  static const int freeSessionsPerWeek = 2;

  int get sessionsThisWeek {
    _resetWeekIfNeeded();
    return _prefs.getInt(_keySessionsThisWeek) ?? 0;
  }

  bool get canStartNewSession =>
      isPremium || sessionsThisWeek < freeSessionsPerWeek;

  Future<void> incrementSessionCount() async {
    _resetWeekIfNeeded();
    final count = sessionsThisWeek + 1;
    await _prefs.setInt(_keySessionsThisWeek, count);
  }

  void _resetWeekIfNeeded() {
    final weekStartStr = _prefs.getString(_keyWeekStart);
    final now = DateTime.now();
    if (weekStartStr == null) {
      _prefs.setString(_keyWeekStart, now.toIso8601String());
      return;
    }
    final weekStart = DateTime.parse(weekStartStr);
    if (now.difference(weekStart).inDays >= 7) {
      _prefs.setInt(_keySessionsThisWeek, 0);
      _prefs.setString(_keyWeekStart, now.toIso8601String());
    }
  }

  // --- Sessions ---
  List<StorySession> getAllSessions() {
    final sessions = _sessions.values.toList();
    sessions.sort((a, b) => b.lastOpenedAt.compareTo(a.lastOpenedAt));
    return sessions;
  }

  StorySession? getSession(String id) =>
      _sessions.values.where((s) => s.id == id).firstOrNull;

  Future<void> saveSession(StorySession session) async {
    await _sessions.put(session.id, session);
  }

  Future<void> deleteSession(String id) async {
    final session = getSession(id);
    if (session == null) return;
    // Delete associated images
    for (final page in session.pages) {
      try {
        final file = File(page.imagePath);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
    await _sessions.delete(id);
  }

  void _purgeExpiredSessions() async {
    final cutoff = DateTime.now()
        .subtract(const Duration(days: _sessionRetentionDays));
    final expired = _sessions.values
        .where((s) => !s.isPremium && s.lastOpenedAt.isBefore(cutoff))
        .map((s) => s.id)
        .toList();
    for (final id in expired) {
      await deleteSession(id);
    }
  }

  // --- Image storage ---
  Future<String> getSessionImageDir(String sessionId) async {
    final base = await getTemporaryDirectory();
    final dir = Directory('${base.path}/sessions/$sessionId/images');
    await dir.create(recursive: true);
    return dir.path;
  }
}
