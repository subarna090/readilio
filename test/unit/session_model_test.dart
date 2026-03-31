import 'package:flutter_test/flutter_test.dart';
import 'package:readilio/models/story_session.dart';

void main() {
  group('StorySession', () {
    StoryPage makePage(int n, String text) => StoryPage(
          pageNumber: n,
          imagePath: '/tmp/page$n.jpg',
          rawText: text,
          words: text.split(' '),
        );

    test('wordCount sums all pages', () {
      final session = StorySession(
        id: '1',
        title: 'Test',
        pages: [makePage(1, 'hello world'), makePage(2, 'foo bar baz')],
        createdAt: DateTime.now(),
        lastOpenedAt: DateTime.now(),
      );
      expect(session.wordCount, equals(5));
    });

    test('formattedDuration shows seconds for < 60s', () {
      final session = StorySession(
        id: '1',
        title: 'Test',
        pages: [],
        createdAt: DateTime.now(),
        lastOpenedAt: DateTime.now(),
        durationSeconds: 45,
      );
      expect(session.formattedDuration, equals('45s'));
    });

    test('formattedDuration shows minutes for >= 60s', () {
      final session = StorySession(
        id: '1',
        title: 'Test',
        pages: [],
        createdAt: DateTime.now(),
        lastOpenedAt: DateTime.now(),
        durationSeconds: 125,
      );
      expect(session.formattedDuration, equals('2m 5s'));
    });
  });

  group('StoryPage', () {
    test('isEdited defaults to false', () {
      final page = StoryPage(
        pageNumber: 1,
        imagePath: '/tmp/x.jpg',
        rawText: 'text',
        words: ['text'],
      );
      expect(page.isEdited, isFalse);
    });
  });
}
