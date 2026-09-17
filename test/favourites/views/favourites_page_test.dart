import 'package:bookshelf/favourites/models/favourite_book_model.dart';
import 'package:bookshelf/favourites/providers/favourites_provider.dart';
import 'package:bookshelf/favourites/repository/favourites_repository.dart';
import 'package:bookshelf/favourites/views/favourites_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockFavouritesRepository extends Mock implements FavouritesRepository {}

class FakeFavouriteBook extends Fake implements FavouriteBook {}

void main() {
  late MockFavouritesRepository repository;
  late FavouritesProvider provider;

  const favouriteBook = FavouriteBook(
    workId: 'OL123W',
    title: 'Clean Code',
    authors: ['Robert C. Martin'],
    firstPublishYear: 2008,
    coverId: null,
  );

  setUpAll(() {
    registerFallbackValue(FakeFavouriteBook());
  });

  setUp(() {
    repository = MockFavouritesRepository();

    provider = FavouritesProvider(repository: repository);
  });

  Widget createWidget() {
    return ChangeNotifierProvider<FavouritesProvider>.value(
      value: provider,
      child: const MaterialApp(home: FavouritesPage()),
    );
  }

  testWidgets('shows loading indicator while favourites are loading', (
    tester,
  ) async {
    when(() => repository.getFavourites()).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 100));

      return [];
    });

    provider.loadFavourites();

    await tester.pumpWidget(createWidget());

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('shows error message when favourites fail to load', (
    tester,
  ) async {
    when(
      () => repository.getFavourites(),
    ).thenThrow(Exception('Database error'));

    await provider.loadFavourites();

    await tester.pumpWidget(createWidget());

    expect(find.text('Failed to load favourites.'), findsOneWidget);
  });

  testWidgets('shows empty state when there are no favourites', (tester) async {
    when(() => repository.getFavourites()).thenAnswer((_) async => []);

    await provider.loadFavourites();

    await tester.pumpWidget(createWidget());

    expect(find.text('No favourite books yet'), findsOneWidget);
  });

  testWidgets('shows favourite books', (tester) async {
    when(
      () => repository.getFavourites(),
    ).thenAnswer((_) async => [favouriteBook]);

    await provider.loadFavourites();

    await tester.pumpWidget(createWidget());

    expect(find.text('Clean Code'), findsOneWidget);

    expect(find.textContaining('Robert C. Martin'), findsOneWidget);

    expect(find.textContaining('2008'), findsOneWidget);

    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('removes favourite when favourite button is tapped', (
    tester,
  ) async {
    when(
      () => repository.getFavourites(),
    ).thenAnswer((_) async => [favouriteBook]);

    when(() => repository.removeFavourite('OL123W')).thenAnswer((_) async {});

    await provider.loadFavourites();

    await tester.pumpWidget(createWidget());

    expect(find.text('Clean Code'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite));

    await tester.pump();

    verify(() => repository.removeFavourite('OL123W')).called(1);

    expect(provider.isFavourite('OL123W'), isFalse);

    expect(find.text('No favourite books yet'), findsOneWidget);
  });
}
