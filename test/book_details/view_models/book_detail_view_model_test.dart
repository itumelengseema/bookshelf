import 'package:bookshelf/features/book_details/domain/repositories/book_detail_repository.dart';
import 'package:bookshelf/features/book_details/presentation/view_models/book_detail_state.dart';
import 'package:bookshelf/features/book_details/presentation/view_models/book_detail_view_model.dart';
import 'package:bookshelf/features/book_details/domain/entities/book_detail.dart'
    show BookDetail;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBookDetailRepository extends Mock implements BookDetailRepository {}

void main() {
  late MockBookDetailRepository repository;
  late BookDetailViewModel viewModel;

  setUp(() {
    repository = MockBookDetailRepository();

    viewModel = BookDetailViewModel(repository: repository);
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('starts in initial state', () {
    expect(viewModel.state, isA<BookDetailInitial>());
  });

  test('moves to loaded state when detail loads successfully', () async {
    when(() => repository.getBookDetail(workId: 'OL123W')).thenAnswer(
      (_) async => const BookDetail(
        title: 'Example Book',
        description: 'Example description',
        subjects: ['Fiction', 'Adventure'],
      ),
    );

    await viewModel.loadBookDetail(workId: 'OL123W');

    expect(viewModel.state, isA<BookDetailLoaded>());

    final state = viewModel.state as BookDetailLoaded;

    expect(state.bookDetail.title, 'Example Book');

    expect(state.bookDetail.subjects.length, 2);
  });

  test('moves to error state when repository fails', () async {
    when(
      () => repository.getBookDetail(workId: 'OL123W'),
    ).thenThrow(const BookDetailException('Failed to load book'));

    await viewModel.loadBookDetail(workId: 'OL123W');

    expect(viewModel.state, isA<BookDetailError>());

    final state = viewModel.state as BookDetailError;

    expect(state.message, 'Failed to load book');
  });
}
