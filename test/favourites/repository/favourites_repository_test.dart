import 'package:bookshelf/database/app_database.dart';
import 'package:bookshelf/favourites/models/favourite_book_model.dart';
import 'package:bookshelf/favourites/repository/favourites_repository.dart';
import 'package:bookshelf/favourites/services/favourites_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late AppDatabase appDatabase;
  late FavouritesRepository repository;

  const testBook = FavouriteBook(
    workId: 'OL123W',
    title: 'Clean Code',
    authors: ['Robert C. Martin'],
    firstPublishYear: 2008,
    coverId: 123,
  );

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    appDatabase = AppDatabase();

    final localDataSource = SqliteFavouritesLocalDataSource(
      appDatabase: appDatabase,
    );

    repository = FavouritesRepository(localDataSource: localDataSource);

    final db = await appDatabase.database;

    await db.delete(AppDatabase.favouritesTable);
  });

  tearDown(() async {
    await appDatabase.close();
  });

  test('adds a favourite and reads it back', () async {
    await repository.addFavourite(testBook);

    final favourites = await repository.getFavourites();

    expect(favourites.length, 1);
    expect(favourites.first.workId, 'OL123W');
    expect(favourites.first.title, 'Clean Code');
    expect(favourites.first.authors, ['Robert C. Martin']);
  });

  test('removes a favourite', () async {
    await repository.addFavourite(testBook);

    await repository.removeFavourite(testBook.workId);

    final favourites = await repository.getFavourites();

    expect(favourites, isEmpty);
  });

  test('reports whether a book is favourited', () async {
    expect(await repository.isFavourite(testBook.workId), isFalse);

    await repository.addFavourite(testBook);

    expect(await repository.isFavourite(testBook.workId), isTrue);
  });

  test('favourite remains available after database restart', () async {
    await repository.addFavourite(testBook);

    await appDatabase.close();

    appDatabase = AppDatabase();

    final restartedDataSource = SqliteFavouritesLocalDataSource(
      appDatabase: appDatabase,
    );

    final restartedRepository = FavouritesRepository(
      localDataSource: restartedDataSource,
    );

    final favourites = await restartedRepository.getFavourites();

    expect(favourites.length, 1);
    expect(favourites.first.workId, 'OL123W');
    expect(favourites.first.title, 'Clean Code');
  });
}
