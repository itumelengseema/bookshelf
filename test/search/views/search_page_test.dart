import 'package:bookshelf/search/models/book_model.dart';
import 'package:bookshelf/search/models/search_result_model.dart';
import 'package:bookshelf/search/repository/search_repository.dart';
import 'package:bookshelf/search/view_models/search_state.dart';
import 'package:bookshelf/search/view_models/search_view_model.dart';
import 'package:bookshelf/search/views/search_page.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

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

  Widget buildTestWidget() {
    return MaterialApp(
      home: ChangeNotifierProvider<SearchViewModel>.value(
        value: viewModel,
        child: SearchPage(),
      ),
    );
  }

  testWidgets('shows loading indicator while searching', (tester) async {
    final completer = Completer<SearchResult>();

    when(
      () => repository.searchBooks(
        query: any(named: 'query'),
        page: any(named: 'page'),
      ),
    ).thenAnswer((_) => completer.future);

    await tester.pumpWidget(
      ChangeNotifierProvider<SearchViewModel>.value(
        value: viewModel,
        child: const MaterialApp(home: SearchPage()),
      ),
    );

    viewModel.search('flutter');

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Finish the fake request before the test ends.
    completer.complete(SearchResult(books: [], totalResults: 0));

    await tester.pumpAndSettle();
  });

  testWidgets('shows books when search returns results', (tester) async {
    final book = Book(
      workId: 'OL123W',
      title: 'Flutter Apprentice',
      authors: ['Eric Windmill'],
      firstPublishYear: 2020,
      coverId: null,
    );

    when(
      () => repository.searchBooks(
        query: any(named: 'query'),
        page: any(named: 'page'),
      ),
    ).thenAnswer((_) async => SearchResult(books: [book], totalResults: 1));

    await tester.pumpWidget(
      ChangeNotifierProvider<SearchViewModel>.value(
        value: viewModel,
        child: const MaterialApp(home: SearchPage()),
      ),
    );

    await viewModel.search('flutter');

    await tester.pump();

    expect(find.text('Flutter Apprentice'), findsOneWidget);

    expect(find.textContaining('Eric Windmill'), findsOneWidget);

    expect(find.textContaining('2020'), findsOneWidget);
  });
  testWidgets('shows empty message for no results', (tester) async {
    viewModel.debugSetState(const SearchEmpty());

    await tester.pumpWidget(buildTestWidget());

    expect(find.text('No books found'), findsOneWidget);
  });

  testWidgets('shows error message when search fails', (tester) async {
    viewModel.debugSetState(const SearchError('Something went wrong.'));

    await tester.pumpWidget(buildTestWidget());

    expect(find.text('Something went wrong.'), findsOneWidget);
  });
}
