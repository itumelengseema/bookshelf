import '../entities/book_detail.dart';

class BookDetailException implements Exception {
  final String message;

  const BookDetailException(this.message);

  @override
  String toString() {
    return 'BookDetailException: $message';
  }
}

abstract interface class BookDetailRepository {
  Future<BookDetail> getBookDetail({required String workId});
}
