import 'dart:convert';

import 'package:bookshelf/book_details/models/book_detail.dart';
import 'package:bookshelf/book_details/repository/book_detail_repository.dart';
import 'package:bookshelf/book_details/services/book_detail_remote_data_source.dart';
import 'package:bookshelf/network/http_client.dart';
import 'package:bookshelf/search/models/book_detail_model.dart';

class OpenLibraryBookDetailDataSource implements BookDetailRemoteDataSource {
  final HttpClient httpClient;

  OpenLibraryBookDetailDataSource({required this.httpClient});

  @override
  Future<BookDetail> getBookDetail({required String workId}) async {
    final response = await httpClient.get(
      'https://openlibrary.org/works/$workId.json',
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BookDetailException(
        'Book detail request failed with status '
        '${response.statusCode}',
      );
    }

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const BookDetailException(
          'Unexpected book detail response format',
        );
      }

      return BookDetail.fromMap(decoded);
    } on BookDetailException {
      rethrow;
    } catch (_) {
      throw const BookDetailException('Failed to parse book detail response');
    }
  }
}
