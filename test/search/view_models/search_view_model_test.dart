import 'package:bookshelf/core/domain/entities/book.dart';
import 'package:bookshelf/features/search/domain/entities/search_result.dart';
import 'package:bookshelf/features/search/domain/repositories/search_repository.dart';
import 'package:bookshelf/features/search/presentation/view_models/search_state.dart';
import 'package:bookshelf/features/search/presentation/view_models/search_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  late MockSearchRepository repository;
  late SearchViewModel viewModel;

  setUp(() {
    repository = MockSearchRepository();

    viewModel = SearchViewModel(repository: repository);
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('starts in initial state', () {
    expect(viewModel.state, isA<SearchInitial>());
  });

  test('moves to results state when search succeeds', () async {
    when(() => repository.searchBooks(query: 'flutter', page: 1)).thenAnswer(
      (_) async => const SearchResult(
        books: [
          Book(
            workId: 'OL1W',
            title: 'Flutter Book',
            authors: ['Test Author'],
            firstPublishYear: 2024,
            coverId: 123,
          ),
        ],
        totalResults: 1,
      ),
    );

    await viewModel.search('flutter');

    expect(viewModel.state, isA<SearchResults>());

    final state = viewModel.state as SearchResults;

    expect(state.books.length, 1);
    expect(state.books.first.title, 'Flutter Book');
  });

  test('moves to empty state when search returns no books', () async {
    when(
      () => repository.searchBooks(query: 'nothing', page: 1),
    ).thenAnswer((_) async => const SearchResult(books: [], totalResults: 0));

    await viewModel.search('nothing');

    expect(viewModel.state, isA<SearchEmpty>());
  });

  test('moves to error state when repository throws', () async {
    when(
      () => repository.searchBooks(query: 'flutter', page: 1),
    ).thenThrow(const SearchException('Network failed'));

    await viewModel.search('flutter');

    expect(viewModel.state, isA<SearchError>());

    final state = viewModel.state as SearchError;

    expect(state.message, 'Network failed');
  });

  test('returns to initial state when query is empty', () async {
    await viewModel.search('');

    expect(viewModel.state, isA<SearchInitial>());
  });

  test('debounces search input before calling repository', () async {
    when(
      () => repository.searchBooks(query: 'flutter', page: 1),
    ).thenAnswer((_) async => const SearchResult(books: [], totalResults: 0));

    viewModel.onSearchChanged('f');
    viewModel.onSearchChanged('fl');
    viewModel.onSearchChanged('flu');
    viewModel.onSearchChanged('flut');
    viewModel.onSearchChanged('flutter');

    verifyNever(
      () => repository.searchBooks(
        query: any(named: 'query'),
        page: any(named: 'page'),
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 500));

    verify(() => repository.searchBooks(query: 'flutter', page: 1)).called(1);
  });

  test('loads the next page and appends results', () async {
    when(() => repository.searchBooks(query: 'flutter', page: 1)).thenAnswer(
      (_) async => const SearchResult(
        books: [
          Book(
            workId: 'OL1W',
            title: 'Flutter One',
            authors: ['Author One'],
            firstPublishYear: 2020,
            coverId: 1,
          ),
        ],
        totalResults: 2,
      ),
    );

    when(() => repository.searchBooks(query: 'flutter', page: 2)).thenAnswer(
      (_) async => const SearchResult(
        books: [
          Book(
            workId: 'OL2W',
            title: 'Flutter Two',
            authors: ['Author Two'],
            firstPublishYear: 2021,
            coverId: 2,
          ),
        ],
        totalResults: 2,
      ),
    );

    await viewModel.search('flutter');
    await viewModel.loadMore();

    final state = viewModel.state as SearchResults;

    expect(state.books.length, 2);
    expect(state.books.first.title, 'Flutter One');
    expect(state.books.last.title, 'Flutter Two');

    verify(() => repository.searchBooks(query: 'flutter', page: 2)).called(1);
  });

  test('does not load more when all results are already loaded', () async {
    when(() => repository.searchBooks(query: 'flutter', page: 1)).thenAnswer(
      (_) async => const SearchResult(
        books: [
          Book(
            workId: 'OL1W',
            title: 'Flutter One',
            authors: ['Author One'],
            firstPublishYear: 2020,
            coverId: 1,
          ),
        ],
        totalResults: 1,
      ),
    );

    await viewModel.search('flutter');
    await viewModel.loadMore();

    verifyNever(() => repository.searchBooks(query: 'flutter', page: 2));
  });
}
