import 'package:bookshelf/features/book_details/domain/entities/book_detail.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BookDetail.fromMap', () {
    test('maps description when it is a string', () {
      final map = {
        'title': 'Example Book',
        'description': 'A normal description.',
        'subjects': ['Fiction', 'Adventure'],
      };

      final detail = BookDetail.fromMap(map);

      expect(detail.description, 'A normal description.');
    });

    test('maps description when it is an object with value', () {
      final map = {
        'title': 'Example Book',
        'description': {'value': 'Description from object.'},
        'subjects': ['Fiction'],
      };

      final detail = BookDetail.fromMap(map);

      expect(detail.description, 'Description from object.');
    });

    test('uses fallback when description is missing', () {
      final map = {
        'title': 'Example Book',
        'subjects': ['Fiction'],
      };

      final detail = BookDetail.fromMap(map);

      expect(detail.description, 'No description available.');
    });

    test('uses empty subjects when subjects is missing', () {
      final map = {'title': 'Example Book'};

      final detail = BookDetail.fromMap(map);

      expect(detail.subjects, isEmpty);
    });
  });
}
