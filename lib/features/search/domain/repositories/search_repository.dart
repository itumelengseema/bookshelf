import '../entities/search_result.dart';

class SearchException implements Exception {
  final String message;

  const SearchException(this.message);

  @override
  String toString() {
    return 'SearchException: $message';
  }
}

abstract interface class SearchRepository {
  Future<SearchResult> searchBooks({required String query, required int page});
}
