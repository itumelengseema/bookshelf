import '../../../../core/domain/entities/book.dart';

class SearchResult {
  final List<Book> books;
  final int totalResults;
  final bool isOffline;

  const SearchResult({
    required this.books,
    required this.totalResults,
    this.isOffline = false,
  });
}
