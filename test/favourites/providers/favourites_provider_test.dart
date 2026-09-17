import 'package:bookshelf/favourites/models/favourite_book_model.dart';
import 'package:bookshelf/favourites/providers/favourites_provider.dart';
import 'package:bookshelf/favourites/repository/favourites_repository.dart';
import 'package:bookshelf/search/models/book_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFavouritesRepository extends Mock implements FavouritesRepository {}

class FakeFavouriteBook extends Fake implements FavouriteBook {}

void main() {
  late MockFavouritesRepository repository;
  late FavouritesProvider provider;

  const testBook = Book(
    workId: 'OL123W',
    title: 'Clean Code',
    authors: ['Robert C. Martin'],
    firstPublishYear: 2008,
    coverId: 123,
  );

  const favouriteBook = FavouriteBook(
    workId: 'OL123W',
    title: 'Clean Code',
    authors: ['Robert C. Martin'],
    firstPublishYear: 2008,
    coverId: 123,
  );

  setUpAll(() {
    registerFallbackValue(FakeFavouriteBook());
  });

  setUp(() {
    repository = MockFavouritesRepository();

    provider = FavouritesProvider(repository: repository);
  });

  test('starts with empty favourites', () {
    expect(provider.favourites, isEmpty);

    expect(provider.isLoading, isFalse);

    expect(provider.errorMessage, isNull);
  });

  test('loads favourites successfully', () async {
    when(
      () => repository.getFavourites(),
    ).thenAnswer((_) async => [favouriteBook]);

    await provider.loadFavourites();

    expect(provider.favourites.length, 1);

    expect(provider.favourites.first.workId, 'OL123W');

    expect(provider.isFavourite('OL123W'), isTrue);

    expect(provider.isLoading, isFalse);

    expect(provider.errorMessage, isNull);
  });

  test('sets error when loading favourites fails', () async {
    when(
      () => repository.getFavourites(),
    ).thenThrow(Exception('Database error'));

    await provider.loadFavourites();

    expect(provider.favourites, isEmpty);

    expect(provider.isLoading, isFalse);

    expect(provider.errorMessage, 'Failed to load favourites.');
  });

  test('adds favourite when book is not already favourited', () async {
    when(() => repository.addFavourite(any())).thenAnswer((_) async {});

    await provider.toggleFavourite(testBook);

    expect(provider.isFavourite(testBook.workId), isTrue);

    expect(provider.favourites.length, 1);

    expect(provider.favourites.first.title, 'Clean Code');

    expect(provider.errorMessage, isNull);

    verify(() => repository.addFavourite(any())).called(1);

    verifyNever(() => repository.removeFavourite(any()));
  });

  test('removes favourite when book is already favourited', () async {
    when(
      () => repository.getFavourites(),
    ).thenAnswer((_) async => [favouriteBook]);

    await provider.loadFavourites();

    expect(provider.isFavourite('OL123W'), isTrue);

    when(() => repository.removeFavourite('OL123W')).thenAnswer((_) async {});

    await provider.toggleFavourite(testBook);

    expect(provider.isFavourite('OL123W'), isFalse);

    expect(provider.favourites, isEmpty);

    expect(provider.errorMessage, isNull);

    verify(() => repository.removeFavourite('OL123W')).called(1);
  });

  test('sets error when adding favourite fails', () async {
    when(
      () => repository.addFavourite(any()),
    ).thenThrow(Exception('Insert failed'));

    await provider.toggleFavourite(testBook);

    expect(provider.isFavourite('OL123W'), isFalse);

    expect(provider.favourites, isEmpty);

    expect(provider.errorMessage, 'Failed to update favourites.');
  });

  test('sets error when removing favourite fails', () async {
    when(
      () => repository.getFavourites(),
    ).thenAnswer((_) async => [favouriteBook]);

    await provider.loadFavourites();

    expect(provider.isFavourite('OL123W'), isTrue);

    when(
      () => repository.removeFavourite('OL123W'),
    ).thenThrow(Exception('Delete failed'));

    await provider.toggleFavourite(testBook);

    expect(provider.isFavourite('OL123W'), isTrue);

    expect(provider.favourites.length, 1);

    expect(provider.errorMessage, 'Failed to update favourites.');
  });
}
