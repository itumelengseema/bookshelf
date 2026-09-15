import 'package:bookshelf/book_details/services/book_detail_remote_data_source.dart';
import 'package:bookshelf/search/models/book_detail_model.dart';

class BookDetailException implements Exception {
  final String message;

  const BookDetailException(this.message);

  @override
  String toString() {
    return 'BookDetailException: $message';
  }
}

class BookDetailRepository {
  final BookDetailRemoteDataSource remoteDataSource;

  BookDetailRepository({required this.remoteDataSource});

  Future<BookDetail> getBookDetail({required String workId}) {
    return remoteDataSource.getBookDetail(workId: workId);
  }
}
