import 'package:bookshelf/search/models/book_detail_model.dart';

abstract interface class BookDetailRemoteDataSource {
  Future<BookDetail> getBookDetail({required String workId});
}
