import '../../domain/entities/book_detail.dart';

abstract interface class BookDetailRemoteDataSource {
  Future<BookDetail> getBookDetail({required String workId});
}
