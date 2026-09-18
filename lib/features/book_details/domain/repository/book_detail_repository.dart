import '../../search/models/book_detail_model.dart';
import '../data/services/book_detail_remote_data_source.dart';

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
