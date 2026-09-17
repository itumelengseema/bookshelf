import 'package:bookshelf/search/services/book_remote_data_source.dart';
import 'package:bookshelf/search/services/search_cache_data_source.dart';

import '../models/search_result_model.dart';

class SearchException implements Exception {
  final String message;

  const SearchException(this.message);

  @override
  String toString() {
    return 'SearchException: $message';
  }
}

class SearchRepository {
  final BookRemoteDataSource remoteDataSource;

  final SearchCacheDataSource cacheDataSource;

  SearchRepository({
    required this.remoteDataSource,
    required this.cacheDataSource,
  });

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
