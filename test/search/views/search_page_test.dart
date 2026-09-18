import 'dart:async';

import 'package:bookshelf/features/favourites/presentation/providers/favourites_provider.dart';
import 'package:bookshelf/features/favourites/domain/repositories/favourites_repository.dart';
import 'package:bookshelf/core/domain/entities/book.dart';
import 'package:bookshelf/features/search/domain/entities/search_result.dart';
import 'package:bookshelf/features/search/domain/repositories/search_repository.dart';
import 'package:bookshelf/features/search/presentation/view_models/search_view_model.dart';
import 'package:bookshelf/features/search/presentation/views/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

class MockFavouritesRepository extends Mock implements FavouritesRepository {}

void main() {
  late MockSearchRepository repository;
  late SearchViewModel viewModel;

  late MockFavouritesRepository favouritesRepository;
  late FavouritesProvider favouritesProvider;

  setUp(() {
    repository = MockSearchRepository();

    viewModel = SearchViewModel(repository: repository);

    favouritesRepository = MockFavouritesRepository();

    favouritesProvider = FavouritesProvider(repository: favouritesRepository);
  });

  Widget createWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SearchViewModel>.value(value: viewModel),

        ChangeNotifierProvider<FavouritesProvider>.value(
          value: favouritesProvider,
        ),
      ],

      child: const MaterialApp(home: SearchPage()),
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

    await tester.pumpWidget(createWidget());

    viewModel.search('flutter');

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(const SearchResult(books: [], totalResults: 0));

    await tester.pumpAndSettle();
  });

  testWidgets('shows books when search returns results', (tester) async {
    const book = Book(
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
    ).thenAnswer(
      (_) async => const SearchResult(books: [book], totalResults: 1),
    );

    await tester.pumpWidget(createWidget());

    await viewModel.search('flutter');

    await tester.pump();

    expect(find.text('Flutter Apprentice'), findsOneWidget);

    expect(find.textContaining('Eric Windmill'), findsOneWidget);

    expect(find.textContaining('2020'), findsOneWidget);

    // NEW:
    // Search result should start
    // with an empty heart.
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });

  testWidgets('shows empty message for no results', (tester) async {
    when(
      () => repository.searchBooks(
        query: any(named: 'query'),
        page: any(named: 'page'),
      ),
    ).thenAnswer((_) async => SearchResult(books: [], totalResults: 0));

    await tester.pumpWidget(createWidget());

    await viewModel.search('something');

    await tester.pump();

    expect(find.text('No books found'), findsOneWidget);
  });

  testWidgets('shows error message when search fails', (tester) async {
    when(
      () => repository.searchBooks(
        query: any(named: 'query'),
        page: any(named: 'page'),
      ),
    ).thenThrow(const SearchException('Search failed'));

    await tester.pumpWidget(createWidget());

    await viewModel.search('flutter');

    await tester.pump();

    expect(find.text('Search failed'), findsOneWidget);
  });
}
