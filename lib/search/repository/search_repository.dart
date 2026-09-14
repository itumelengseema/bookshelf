import 'dart:convert';
import 'package:bookshelf/network/http_client.dart';
import '../models/book_model.dart';
import '../models/search_result_model.dart';

class SearchException implements Exception {
  final String message;

  const SearchException(this.message);

  @override
  String toString() => 'SearchException: $message';
}

class SearchRepository {
  final HttpClient httpClient;

  SearchRepository({required this.httpClient});

  Future<SearchResult> searchBooks({
    required String query,
    required int page,
  }) async {
    final encodedQuery = Uri.encodeQueryComponent(query);

    final response = await httpClient.get(
      'https://openlibrary.org/search.json?q=$encodedQuery&page=$page',
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SearchException(
        'Search request failed with status ${response.statusCode}',
      );
    }

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const SearchException('Unexpected response format');
      }

      final rawDocs = decoded['docs'];

      if (rawDocs is! List) {
        throw const SearchException('Missing or invalid docs field');
      }

      final books = rawDocs
          .whereType<Map<String, dynamic>>()
          .map(Book.fromMap)
          .toList();

      final totalResults = (decoded['numFound'] as num?)?.toInt() ?? 0;

      return SearchResult(books: books, totalResults: totalResults);
    } on SearchException {
      rethrow;
    } catch (_) {
      throw const SearchException('Failed to parse search response');
    }
  }
}
