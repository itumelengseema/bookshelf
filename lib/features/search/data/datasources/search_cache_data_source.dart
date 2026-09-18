import '../../../../core/database/app_database.dart';
import '../../../../core/domain/entities/book.dart';

abstract interface class SearchCacheDataSource {
  Future<void> saveSearchResults({
    required String query,
    required List<Book> books,
  });

  Future<List<Book>> getCachedResults({required String query});
}

class SqliteSearchCacheDataSource implements SearchCacheDataSource {
  final AppDatabase appDatabase;

  SqliteSearchCacheDataSource({required this.appDatabase});

  @override
  Future<void> saveSearchResults({
    required String query,
    required List<Book> books,
  }) async {
    final db = await appDatabase.database;

    await db.delete(
      AppDatabase.searchCacheTable,
      where: 'query = ?',
      whereArgs: [query],
    );

    for (var i = 0; i < books.length; i++) {
      final book = books[i];

      await db.insert(AppDatabase.searchCacheTable, {
        'query': query,
        'work_id': book.workId,
        'title': book.title,
        'authors': book.authors.join('||'),
        'first_publish_year': book.firstPublishYear,
        'cover_id': book.coverId,
        'position': i,
      });
    }
  }

  @override
  Future<List<Book>> getCachedResults({required String query}) async {
    final db = await appDatabase.database;

    final rows = await db.query(
      AppDatabase.searchCacheTable,
      where: 'query = ?',
      whereArgs: [query],
      orderBy: 'position ASC',
    );

    return rows.map((row) {
      final authorsValue = row['authors'] as String? ?? '';

      return Book(
        workId: row['work_id'] as String,
        title: row['title'] as String,
        authors: authorsValue.isEmpty ? <String>[] : authorsValue.split('||'),
        firstPublishYear: row['first_publish_year'] as int?,
        coverId: row['cover_id'] as int?,
      );
    }).toList();
  }
}
