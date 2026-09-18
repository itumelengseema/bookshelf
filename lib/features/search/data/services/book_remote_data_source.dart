import 'package:bookshelf/search/models/search_result_model.dart';

abstract interface class BookRemoteDataSource {
  Future<SearchResult> searchBooks({required String query, required int page});
}
