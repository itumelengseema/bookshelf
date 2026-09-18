class BookDetail {
  final String title;
  final String description;
  final List<String> subjects;

  const BookDetail({
    required this.title,
    required this.description,
    required this.subjects,
  });

  factory BookDetail.fromMap(Map<String, dynamic> map) {
    final rawDescription = map['description'];

    String description;

    if (rawDescription is String) {
      description = rawDescription;
    } else if (rawDescription is Map<String, dynamic>) {
      description =
          rawDescription['value'] as String? ?? 'No description available.';
    } else {
      description = 'No description available.';
    }

    final rawSubjects = map['subjects'];

    final subjects = rawSubjects is List
        ? rawSubjects.whereType<String>().toList()
        : <String>[];

    return BookDetail(
      title: map['title'] as String? ?? 'Untitled',
      description: description,
      subjects: subjects,
    );
  }
}
