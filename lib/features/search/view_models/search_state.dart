import '../models/book_model.dart';

sealed class SearchState {
  const SearchState();
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchResults extends SearchState {
  final List<Book> books;
  final bool isLoadingMore;
  final bool isOffline;

  const SearchResults({
    required this.books,
    this.isLoadingMore = false,
    this.isOffline = false,
  });
}

class SearchEmpty extends SearchState {
  const SearchEmpty();
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);
}
