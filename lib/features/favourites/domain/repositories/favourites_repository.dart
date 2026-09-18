import '../entities/favourite_book.dart';

abstract interface class FavouritesRepository {
  Future<void> addFavourite(FavouriteBook book);

  Future<void> removeFavourite(String workId);

  Future<List<FavouriteBook>> getFavourites();

  Future<bool> isFavourite(String workId);
}
