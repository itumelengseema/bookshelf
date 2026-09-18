import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/favourite_book.dart';

abstract interface class FavouritesLocalDataSource {
  Future<void> addFavourite(FavouriteBook book);

  Future<void> removeFavourite(String workId);

  Future<List<FavouriteBook>> getFavourites();

  Future<bool> isFavourite(String workId);
}

class SqliteFavouritesLocalDataSource implements FavouritesLocalDataSource {
  final AppDatabase appDatabase;

  SqliteFavouritesLocalDataSource({required this.appDatabase});

  @override
  Future<void> addFavourite(FavouriteBook book) async {
    final db = await appDatabase.database;

    await db.insert(
      AppDatabase.favouritesTable,
      book.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> removeFavourite(String workId) async {
    final db = await appDatabase.database;

    await db.delete(
      AppDatabase.favouritesTable,
      where: 'work_id = ?',
      whereArgs: [workId],
    );
  }

  @override
  Future<List<FavouriteBook>> getFavourites() async {
    final db = await appDatabase.database;

    final rows = await db.query(
      AppDatabase.favouritesTable,
      orderBy: 'title ASC',
    );

    return rows.map(FavouriteBook.fromMap).toList();
  }

  @override
  Future<bool> isFavourite(String workId) async {
    final db = await appDatabase.database;

    final rows = await db.query(
      AppDatabase.favouritesTable,
      columns: ['work_id'],
      where: 'work_id = ?',
      whereArgs: [workId],
      limit: 1,
    );

    return rows.isNotEmpty;
  }
}
