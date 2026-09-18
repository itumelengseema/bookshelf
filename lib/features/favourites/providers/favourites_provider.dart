import 'package:bookshelf/favourites/models/favourite_book_model.dart';
import 'package:bookshelf/favourites/repository/favourites_repository.dart';
import 'package:bookshelf/search/models/book_model.dart';
import 'package:flutter/foundation.dart';

class FavouritesProvider extends ChangeNotifier {
  final FavouritesRepository repository;

  FavouritesProvider({required this.repository});

  List<FavouriteBook> _favourites = [];

  List<FavouriteBook> get favourites => List.unmodifiable(_favourites);

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  Future<void> loadFavourites() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _favourites = List.of(await repository.getFavourites());
    } catch (_) {
      _errorMessage = 'Failed to load favourites.';
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  bool isFavourite(String workId) {
    return _favourites.any((book) => book.workId == workId);
  }

  Future<void> toggleFavourite(Book book) async {
    final currentlyFavourite = isFavourite(book.workId);

    try {
      if (currentlyFavourite) {
        await repository.removeFavourite(book.workId);

        _favourites.removeWhere((favourite) => favourite.workId == book.workId);
      } else {
        final favourite = FavouriteBook.fromBook(book);

        await repository.addFavourite(favourite);

        _favourites.add(favourite);
      }

      _errorMessage = null;

      notifyListeners();
    } catch (_) {
      _errorMessage = 'Failed to update favourites.';

      notifyListeners();
    }
  }
}
