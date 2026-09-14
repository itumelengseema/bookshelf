import 'package:bookshelf/search/repository/search_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bookshelf/network/http_client.dart';

class MockHttpClient extends Mock implements HttpClient {}

void main() {
  late MockHttpClient httpClient;
  late SearchRepository repository;

  setUp(() {
    httpClient = MockHttpClient();
    repository = SearchRepository(httpClient: httpClient);
  });

  group('SearchRepository.searchBooks', () {
    test('returns books for a successful response', () async {
      when(() => httpClient.get(any())).thenAnswer(
        (_) async => HttpResponse(
          statusCode: 200,
          body: '''
          {
            "numFound": 1,
            "docs": [
              {
                "key": "/works/OL123W",
                "title": "Clean Code",
                "author_name": ["Robert C. Martin"],
                "first_publish_year": 2008,
                "cover_i": 123456
              }
            ]
          }
          ''',
        ),
      );

      final result = await repository.searchBooks(query: 'clean code', page: 1);

      expect(result.books.length, 1);
      expect(result.books.first.title, 'Clean Code');
      expect(result.totalResults, 1);
    });

    test('throws on HTTP error response', () async {
      when(() => httpClient.get(any())).thenAnswer(
        (_) async => HttpResponse(statusCode: 500, body: 'Server error'),
      );

      expect(
        () => repository.searchBooks(query: 'flutter', page: 1),
        throwsA(isA<SearchException>()),
      );
    });

    test('throws on malformed JSON', () async {
      when(() => httpClient.get(any())).thenAnswer(
        (_) async => HttpResponse(statusCode: 200, body: 'not-json'),
      );

      expect(
        () => repository.searchBooks(query: 'flutter', page: 1),
        throwsA(isA<SearchException>()),
      );
    });

    test('returns an empty list for an empty result set', () async {
      when(() => httpClient.get(any())).thenAnswer(
        (_) async => HttpResponse(
          statusCode: 200,
          body: '''
          {
            "numFound": 0,
            "docs": []
          }
          ''',
        ),
      );

      final result = await repository.searchBooks(
        query: 'something impossible',
        page: 1,
      );

      expect(result.books, isEmpty);
      expect(result.totalResults, 0);
    });
  });
}
