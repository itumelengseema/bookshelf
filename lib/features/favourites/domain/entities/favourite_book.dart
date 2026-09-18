import '../../../../core/domain/entities/book.dart';

class FavouriteBook {
  final String workId;
  final String title;
  final List<String> authors;
  final int? firstPublishYear;
  final int? coverId;

  const FavouriteBook({
    required this.workId,
    required this.title,
    required this.authors,
    required this.firstPublishYear,
    required this.coverId,
  });

  factory FavouriteBook.fromBook(Book book) {
    return FavouriteBook(
      workId: book.workId,
      title: book.title,
      authors: book.authors,
      firstPublishYear: book.firstPublishYear,
      coverId: book.coverId,
    );
  }

  factory FavouriteBook.fromMap(Map<String, dynamic> map) {
    final authorsValue = map['authors'] as String? ?? '';

    return FavouriteBook(
      workId: map['work_id'] as String,
      title: map['title'] as String,
      authors: authorsValue.isEmpty ? <String>[] : authorsValue.split('||'),
      firstPublishYear: map['first_publish_year'] as int?,
      coverId: map['cover_id'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'work_id': workId,
      'title': title,
      'authors': authors.join('||'),
      'first_publish_year': firstPublishYear,
      'cover_id': coverId,
    };
  }

  Book toBook() {
    return Book(
      workId: workId,
      title: title,
      authors: authors,
      firstPublishYear: firstPublishYear,
      coverId: coverId,
    );
  }
}
