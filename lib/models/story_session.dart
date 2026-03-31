import 'package:hive_flutter/hive_flutter.dart';

part 'story_session.g.dart';

@HiveType(typeId: 0)
class StorySession extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  List<StoryPage> pages;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime lastOpenedAt;

  @HiveField(5)
  int durationSeconds;

  @HiveField(6)
  bool isPremium;

  StorySession({
    required this.id,
    required this.title,
    required this.pages,
    required this.createdAt,
    required this.lastOpenedAt,
    this.durationSeconds = 0,
    this.isPremium = false,
  });

  String get formattedDuration {
    if (durationSeconds < 60) return '${durationSeconds}s';
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '${m}m ${s}s';
  }

  int get wordCount =>
      pages.fold(0, (sum, p) => sum + p.words.length);
}

@HiveType(typeId: 1)
class StoryPage extends HiveObject {
  @HiveField(0)
  int pageNumber;

  @HiveField(1)
  String imagePath;

  @HiveField(2)
  String rawText;

  @HiveField(3)
  List<String> words;

  @HiveField(4)
  double avgConfidence;

  @HiveField(5)
  bool isEdited;

  StoryPage({
    required this.pageNumber,
    required this.imagePath,
    required this.rawText,
    required this.words,
    this.avgConfidence = 1.0,
    this.isEdited = false,
  });
}
