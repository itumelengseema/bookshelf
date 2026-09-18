import '../../domain/entities/book_detail.dart';
import '../../domain/repositories/book_detail_repository.dart';
import '../datasources/book_detail_remote_data_source.dart';

class BookDetailRepositoryImpl implements BookDetailRepository {
  final BookDetailRemoteDataSource remoteDataSource;

  BookDetailRepositoryImpl({required this.remoteDataSource});

  @override
  Future<BookDetail> getBookDetail({required String workId}) {
    return remoteDataSource.getBookDetail(workId: workId);
  }
}
