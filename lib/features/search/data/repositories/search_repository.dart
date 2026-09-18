import '../datasources/book_remote_data_source.dart';
import '../datasources/search_cache_data_source.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final BookRemoteDataSource remoteDataSource;

  final SearchCacheDataSource cacheDataSource;

  SearchRepositoryImpl({
    required this.remoteDataSource,
    required this.cacheDataSource,
  });

  @override
  Future<SearchResult> searchBooks({
    required String query,
    required int page,
  }) async {
    try {
      final result = await remoteDataSource.searchBooks(
        query: query,
        page: page,
      );

      if (page == 1) {
        await cacheDataSource.saveSearchResults(
          query: query,
          books: result.books,
        );
      }

      return SearchResult(
        books: result.books,
        totalResults: result.totalResults,
        isOffline: false,
      );
    } catch (_) {
      if (page != 1) {
        rethrow;
      }

      final cachedBooks = await cacheDataSource.getCachedResults(query: query);

      if (cachedBooks.isNotEmpty) {
        return SearchResult(
          books: cachedBooks,
          totalResults: cachedBooks.length,
          isOffline: true,
        );
      }

      throw const SearchException(
        'Unable to load books. Check your internet connection.',
      );
    }
  }
}
