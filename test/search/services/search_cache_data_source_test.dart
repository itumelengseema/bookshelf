import 'package:bookshelf/database/app_database.dart';
import 'package:bookshelf/search/models/book_model.dart';
import 'package:bookshelf/search/services/search_cache_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late AppDatabase appDatabase;
  late SqliteSearchCacheDataSource dataSource;

  const flutterBook = Book(
    workId: 'OL1W',
    title: 'Flutter Apprentice',
    authors: ['Eric Windmill'],
    firstPublishYear: 2021,
    coverId: 101,
  );

  const dartBook = Book(
    workId: 'OL2W',
    title: 'Dart in Action',
    authors: ['Chris Buckett'],
    firstPublishYear: 2013,
    coverId: null,
  );

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    appDatabase = AppDatabase();

    dataSource = SqliteSearchCacheDataSource(appDatabase: appDatabase);

    final db = await appDatabase.database;

    await db.delete(AppDatabase.searchCacheTable);
  });

  tearDown(() async {
    await appDatabase.close();
  });

  test('saves and returns cached search results', () async {
    await dataSource.saveSearchResults(
      query: 'flutter',
      books: const [flutterBook, dartBook],
    );

    final results = await dataSource.getCachedResults(query: 'flutter');

    expect(results.length, 2);

    expect(results[0].workId, 'OL1W');

    expect(results[0].title, 'Flutter Apprentice');

    expect(results[0].authors, ['Eric Windmill']);

    expect(results[0].firstPublishYear, 2021);

    expect(results[0].coverId, 101);

    expect(results[1].title, 'Dart in Action');

    expect(results[1].coverId, isNull);
  });

  test('returns cached books in original order', () async {
    await dataSource.saveSearchResults(
      query: 'programming',
      books: const [dartBook, flutterBook],
    );

    final results = await dataSource.getCachedResults(query: 'programming');

    expect(results.length, 2);

    expect(results[0].workId, 'OL2W');

    expect(results[1].workId, 'OL1W');
  });

  test('replaces previous cache for the same query', () async {
    await dataSource.saveSearchResults(
      query: 'flutter',
      books: const [flutterBook, dartBook],
    );

    await dataSource.saveSearchResults(
      query: 'flutter',
      books: const [dartBook],
    );

    final results = await dataSource.getCachedResults(query: 'flutter');

    expect(results.length, 1);

    expect(results.first.workId, 'OL2W');
  });

  test('keeps caches for different queries separate', () async {
    await dataSource.saveSearchResults(
      query: 'flutter',
      books: const [flutterBook],
    );

    await dataSource.saveSearchResults(query: 'dart', books: const [dartBook]);

    final flutterResults = await dataSource.getCachedResults(query: 'flutter');

    final dartResults = await dataSource.getCachedResults(query: 'dart');

    expect(flutterResults.length, 1);

    expect(flutterResults.first.workId, 'OL1W');

    expect(dartResults.length, 1);

    expect(dartResults.first.workId, 'OL2W');
  });

  test('returns empty list when no cache exists', () async {
    final results = await dataSource.getCachedResults(query: 'unknown');

    expect(results, isEmpty);
  });

  test('handles book with no authors', () async {
    const bookWithoutAuthor = Book(
      workId: 'OL3W',
      title: 'Unknown Book',
      authors: [],
      firstPublishYear: null,
      coverId: null,
    );

    await dataSource.saveSearchResults(
      query: 'unknown',
      books: const [bookWithoutAuthor],
    );

    final results = await dataSource.getCachedResults(query: 'unknown');

    expect(results.length, 1);

    expect(results.first.authors, isEmpty);

    expect(results.first.firstPublishYear, isNull);

    expect(results.first.coverId, isNull);
  });
}
