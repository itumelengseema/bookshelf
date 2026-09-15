import 'package:bookshelf/search/models/book_model.dart';
import 'package:bookshelf/search/models/search_result_model.dart';
import 'package:bookshelf/search/repository/search_repository.dart';
import 'package:bookshelf/search/view_models/search_state.dart';
import 'package:bookshelf/search/view_models/search_view_model.dart';
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
}
