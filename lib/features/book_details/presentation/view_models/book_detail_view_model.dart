import 'package:flutter/cupertino.dart';
import '../../domain/repositories/book_detail_repository.dart';
import 'book_detail_state.dart';

class BookDetailViewModel extends ChangeNotifier {
  final BookDetailRepository repository;

  BookDetailViewModel({required this.repository});

  BookDetailState _state = const BookDetailInitial();

  BookDetailState get state => _state;

  Future<void> loadBookDetail({required String workId}) async {
    _state = const BookDetailLoading();
    notifyListeners();

    try {
      final bookDetail = await repository.getBookDetail(workId: workId);

      _state = BookDetailLoaded(bookDetail: bookDetail);
    } on BookDetailException catch (error) {
      _state = BookDetailError(error.message);
    } catch (_) {
      _state = const BookDetailError('Something went wrong.');
    }

    notifyListeners();
  }
}
