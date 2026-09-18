import '../../domain/entities/book_detail.dart';

sealed class BookDetailState {
  const BookDetailState();
}

class BookDetailInitial extends BookDetailState {
  const BookDetailInitial();
}

class BookDetailLoading extends BookDetailState {
  const BookDetailLoading();
}

class BookDetailLoaded extends BookDetailState {
  final BookDetail bookDetail;

  const BookDetailLoaded({required this.bookDetail});
}

class BookDetailError extends BookDetailState {
  final String message;

  const BookDetailError(this.message);
}
