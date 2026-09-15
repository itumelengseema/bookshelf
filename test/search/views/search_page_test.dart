import 'package:bookshelf/search/models/book_model.dart';
import 'package:bookshelf/search/repository/search_repository.dart';
import 'package:bookshelf/search/view_models/search_state.dart';
import 'package:bookshelf/search/view_models/search_view_model.dart';
import 'package:bookshelf/search/views/search_page.dart';

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
    when(() => repository.searchBooks(query: 'flutter', page: 1)).thenAnswer((
      _,
    ) async {
      await Future<void>.delayed(const Duration(seconds: 1));

      throw const SearchException('Delayed response');
    });

    await tester.pumpWidget(buildTestWidget());

    viewModel.search('flutter');

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows books when search returns results', (tester) async {
    viewModel.debugSetState(
      const SearchResults(
        books: [
          Book(
            workId: 'OL1W',
            title: 'Flutter in Action',
            authors: ['Eric Windmill'],
            firstPublishYear: 2020,
            coverId: 123,
          ),
        ],
      ),
    );

    await tester.pumpWidget(buildTestWidget());

    expect(find.text('Flutter in Action'), findsOneWidget);

    expect(find.text('Eric Windmill'), findsOneWidget);
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
