import 'package:bookshelf/features/book_details/data/repositories/book_detail_repository_impl.dart';
import 'package:bookshelf/features/book_details/data/datasources/open_library_book_detail_data_source.dart';
import 'package:bookshelf/features/book_details/domain/repositories/book_detail_repository.dart';
import 'package:bookshelf/core/network/http_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements HttpClient {}

void main() {
  late MockHttpClient httpClient;
  late OpenLibraryBookDetailDataSource remoteDataSource;
  late BookDetailRepository repository;

  setUp(() {
    httpClient = MockHttpClient();

    remoteDataSource = OpenLibraryBookDetailDataSource(httpClient: httpClient);

    repository = BookDetailRepositoryImpl(remoteDataSource: remoteDataSource);
  });

  group('BookDetailRepository.getBookDetail', () {
    test('returns book detail for a successful response', () async {
      when(() => httpClient.get(any())).thenAnswer(
        (_) async => HttpResponse(
          statusCode: 200,
          body: '''
          {
            "title": "Example Book",
            "description": "A detailed description.",
            "subjects": [
              "Fiction",
              "Adventure"
            ]
          }
          ''',
        ),
      );

      final result = await repository.getBookDetail(workId: 'OL123W');

      expect(result.title, 'Example Book');
      expect(result.description, 'A detailed description.');
      expect(result.subjects, ['Fiction', 'Adventure']);
    });

    test('throws on HTTP error response', () async {
      when(() => httpClient.get(any())).thenAnswer(
        (_) async => HttpResponse(statusCode: 404, body: 'Not found'),
      );

      expect(
        () => repository.getBookDetail(workId: 'OL123W'),
        throwsA(isA<BookDetailException>()),
      );
    });

    test('throws on malformed JSON', () async {
      when(() => httpClient.get(any())).thenAnswer(
        (_) async => HttpResponse(statusCode: 200, body: 'not-json'),
      );

      expect(
        () => repository.getBookDetail(workId: 'OL123W'),
        throwsA(isA<BookDetailException>()),
      );
    });
  });
}
