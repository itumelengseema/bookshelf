import 'package:bookshelf/network/http_client.dart';
import 'package:bookshelf/search/models/book_model.dart';
import 'package:bookshelf/search/repository/search_repository.dart';
import 'package:bookshelf/search/services/open_library_remote_data_source.dart';
import 'package:bookshelf/search/services/search_cache_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements HttpClient {}

class MockSearchCacheDataSource extends Mock implements SearchCacheDataSource {}

void main() {
  late MockHttpClient httpClient;
  late MockSearchCacheDataSource cacheDataSource;

  late OpenLibraryRemoteDataSource remoteDataSource;
  late SearchRepository repository;

  setUp(() {
    httpClient = MockHttpClient();

    cacheDataSource = MockSearchCacheDataSource();

    remoteDataSource = OpenLibraryRemoteDataSource(httpClient: httpClient);

    repository = SearchRepository(
      remoteDataSource: remoteDataSource,
      cacheDataSource: cacheDataSource,
    );
  });

  test('returns books when search succeeds', () async {
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
                "author_name": [
                  "Robert C. Martin"
                ],
                "first_publish_year": 2008,
                "cover_i": 123
              }
            ]
          }
          ''',
      ),
    );

    when(
      () => cacheDataSource.saveSearchResults(
        query: any(named: 'query'),
        books: any(named: 'books'),
      ),
    ).thenAnswer((_) async {});

    final result = await repository.searchBooks(query: 'clean code', page: 1);

    expect(result.books.length, 1);

    expect(result.books.first.title, 'Clean Code');

    expect(result.isOffline, isFalse);

    verify(
      () => cacheDataSource.saveSearchResults(
        query: 'clean code',
        books: any(named: 'books'),
      ),
    ).called(1);
  });

  test(
    'throws SearchException when request fails and no cached results exist',
    () async {
      when(
        () => httpClient.get(any()),
      ).thenAnswer((_) async => HttpResponse(statusCode: 500, body: ''));

      // NEW:
      // No cached fallback exists.
      when(
        () => cacheDataSource.getCachedResults(query: 'flutter'),
      ).thenAnswer((_) async => <Book>[]);

      expect(
        () => repository.searchBooks(query: 'flutter', page: 1),
        throwsA(isA<SearchException>()),
      );
    },
  );

  test(
    'throws SearchException when json is malformed and no cache exists',
    () async {
      when(() => httpClient.get(any())).thenAnswer(
        (_) async => HttpResponse(statusCode: 200, body: 'not-json'),
      );

      when(
        () => cacheDataSource.getCachedResults(query: 'flutter'),
      ).thenAnswer((_) async => <Book>[]);

      expect(
        () => repository.searchBooks(query: 'flutter', page: 1),
        throwsA(isA<SearchException>()),
      );
    },
  );

  test('returns empty result when search succeeds with no books', () async {
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

    when(
      () => cacheDataSource.saveSearchResults(
        query: any(named: 'query'),
        books: any(named: 'books'),
      ),
    ).thenAnswer((_) async {});

    final result = await repository.searchBooks(query: 'nothing', page: 1);

    expect(result.books, isEmpty);

    expect(result.totalResults, 0);

    expect(result.isOffline, isFalse);
  });

  test('returns cached books when remote request fails', () async {
    const cachedBook = Book(
      workId: 'OL999W',
      title: 'Cached Flutter Book',
      authors: ['Offline Author'],
      firstPublishYear: 2024,
      coverId: null,
    );

    when(
      () => httpClient.get(any()),
    ).thenThrow(Exception('No internet connection'));

    when(
      () => cacheDataSource.getCachedResults(query: 'flutter'),
    ).thenAnswer((_) async => const [cachedBook]);

    final result = await repository.searchBooks(query: 'flutter', page: 1);

    expect(result.books.length, 1);

    expect(result.books.first.title, 'Cached Flutter Book');

    expect(result.isOffline, isTrue);
  });

  test('does not use cache fallback for pagination failure', () async {
    when(
      () => httpClient.get(any()),
    ).thenThrow(Exception('No internet connection'));

    expect(
      () => repository.searchBooks(query: 'flutter', page: 2),
      throwsException,
    );

    verifyNever(
      () => cacheDataSource.getCachedResults(query: any(named: 'query')),
    );
  });
}
