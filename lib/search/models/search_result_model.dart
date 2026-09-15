import 'book_model.dart';

class SearchResult {
  final List<Book> books;
  final int totalResults;

  const SearchResult({required this.books, required this.totalResults});
}
