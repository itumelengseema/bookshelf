import '../datasources/favourites_local_data_source.dart';
import '../../domain/entities/favourite_book.dart';
import '../../domain/repositories/favourites_repository.dart';

class FavouritesRepositoryImpl implements FavouritesRepository {
  final FavouritesLocalDataSource localDataSource;

  FavouritesRepositoryImpl({required this.localDataSource});

  @override
  Future<void> addFavourite(FavouriteBook book) {
    return localDataSource.addFavourite(book);
  }

  @override
  Future<void> removeFavourite(String workId) {
    return localDataSource.removeFavourite(workId);
  }

  @override
  Future<List<FavouriteBook>> getFavourites() {
    return localDataSource.getFavourites();
  }

  @override
  Future<bool> isFavourite(String workId) {
    return localDataSource.isFavourite(workId);
  }
}
