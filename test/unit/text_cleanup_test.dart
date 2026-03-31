import 'package:flutter_test/flutter_test.dart';
import 'package:readilio/services/text_cleanup_service.dart';

void main() {
  final svc = TextCleanupService();

  group('TextCleanupService.clean', () {
    test('replaces pipe with l', () {
      expect(svc.clean('|ove'), equals('love'));
    });

    test('fixes double spaces', () {
      expect(svc.clean('hello  world'), equals('hello world'));
    });

    test('normalises curly quotes', () {
      // U+201C left double quotation mark, U+201D right double quotation mark
      expect(svc.clean('\u201cHello\u201d'), equals('"Hello"'));
    });

    test('removes hyphenated line break', () {
      expect(svc.clean('some-\nthing'), equals('something'));
    });

    test('collapses triple newlines to double', () {
      final result = svc.clean('a\n\n\nb');
      expect(result, equals('a\n\nb'));
    });

    test('removes stutter duplicate short words', () {
      expect(svc.clean('the the cat'), equals('the cat'));
    });

    test('trims whitespace', () {
      expect(svc.clean('  hello  '), equals('hello'));
    });

    test('leaves normal text unchanged', () {
      const text = 'Once upon a time, a lion roared.';
      expect(svc.clean(text), equals(text));
    });
  });

  group('TextCleanupService.tokenizeWords', () {
    test('splits on whitespace', () {
      expect(svc.tokenizeWords('hello world'), equals(['hello', 'world']));
    });

    test('handles multiple spaces', () {
      expect(svc.tokenizeWords('a  b'), equals(['a', 'b']));
    });

    test('empty string returns empty list', () {
      expect(svc.tokenizeWords(''), isEmpty);
    });
  });

  group('TextCleanupService.splitSentences', () {
    test('splits on period', () {
      final sentences =
          svc.splitSentences('Hello world. How are you?');
      expect(sentences.length, equals(2));
    });

    test('single sentence returns list of one', () {
      final sentences = svc.splitSentences('Just one sentence');
      expect(sentences.length, equals(1));
    });
  });
}
