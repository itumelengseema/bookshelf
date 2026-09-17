import 'package:bookshelf/favourites/models/favourite_book_model.dart';
import 'package:bookshelf/favourites/services/favourites_local_data_source.dart';

class FavouritesRepository {
  final FavouritesLocalDataSource localDataSource;

  FavouritesRepository({required this.localDataSource});

  Future<void> addFavourite(FavouriteBook book) {
    return localDataSource.addFavourite(book);
  }

  Future<void> removeFavourite(String workId) {
    return localDataSource.removeFavourite(workId);
  }

  Future<List<FavouriteBook>> getFavourites() {
    return localDataSource.getFavourites();
  }

  Future<bool> isFavourite(String workId) {
    return localDataSource.isFavourite(workId);
  }
}
