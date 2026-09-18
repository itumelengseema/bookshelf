import '../../domain/entities/search_result.dart';

abstract interface class BookRemoteDataSource {
  Future<SearchResult> searchBooks({required String query, required int page});
}
