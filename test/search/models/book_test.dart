import 'package:bookshelf/core/domain/entities/book.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Book.fromMap', () {
    test('maps a complete Open Library search result', () {
      final map = {
        'key': '/works/OL123W',
        'title': 'Clean Code',
        'author_name': ['Robert C. Martin'],
        'first_publish_year': 2008,
        'cover_i': 123456,
      };

      final book = Book.fromMap(map);

      expect(book.workId, 'OL123W');
      expect(book.title, 'Clean Code');
      expect(book.authors, ['Robert C. Martin']);
      expect(book.firstPublishYear, 2008);
      expect(book.coverId, 123456);
    });

    test('uses an empty author list when author_name is missing', () {
      final map = {
        'key': '/works/OL123W',
        'title': 'Unknown Author Book',
        'first_publish_year': 2001,
        'cover_i': 123456,
      };

      final book = Book.fromMap(map);

      expect(book.authors, isEmpty);
    });

    test('sets coverId to null when cover_i is missing', () {
      final map = {
        'key': '/works/OL123W',
        'title': 'Book Without Cover',
        'author_name': ['Author One'],
        'first_publish_year': 2001,
      };

      final book = Book.fromMap(map);

      expect(book.coverId, isNull);
    });

    test(
      'sets firstPublishYear to null when first_publish_year is missing',
      () {
        final map = {
          'key': '/works/OL123W',
          'title': 'Book Without Year',
          'author_name': ['Author One'],
          'cover_i': 123456,
        };

        final book = Book.fromMap(map);

        expect(book.firstPublishYear, isNull);
      },
    );

    test('extracts workId from the key field', () {
      final map = {'key': '/works/OL893414W', 'title': 'Example'};

      final book = Book.fromMap(map);

      expect(book.workId, 'OL893414W');
    });
  });
}
