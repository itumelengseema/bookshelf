class Book {
  final String workId;
  final String title;
  final List<String> authors;
  final int? firstPublishYear;
  final int? coverId;

  const Book({
    required this.workId,
    required this.title,
    required this.authors,
    required this.firstPublishYear,
    required this.coverId,
  });

  factory Book.fromMap(Map<String, dynamic> map) {
    final key = map['key'] as String? ?? '';

    final workId = key.isEmpty ? '' : key.split('/').last;

    final authorData = map['author_name'];

    final authors = authorData is List
        ? authorData.whereType<String>().toList()
        : <String>[];

    return Book(
      workId: workId,
      title: map['title'] as String? ?? 'Untitled',
      authors: authors,
      firstPublishYear: map['first_publish_year'] as int?,
      coverId: map['cover_i'] as int?,
    );
  }

  String get coverUrl {
    if (coverId == null) {
      return '';
    }

    return 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';
  }

  String get authorDisplay {
    if (authors.isEmpty) {
      return 'Unknown author';
    }

    return authors.join(', ');
  }

  String get yearDisplay {
    if (firstPublishYear == null) {
      return 'Year unknown';
    }

    return firstPublishYear.toString();
  }
}
