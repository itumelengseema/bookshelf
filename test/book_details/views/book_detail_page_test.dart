import 'dart:async';
import 'package:bookshelf/app/app_dependencies.dart';
import 'package:bookshelf/book_details/repository/book_detail_repository.dart';
import 'package:bookshelf/book_details/view_models/book_detail_view_model.dart';
import 'package:bookshelf/book_details/views/book_detail_page.dart';
import 'package:bookshelf/search/models/book_detail_model.dart';
import 'package:bookshelf/search/models/book_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockAppDependencies extends Mock implements AppDependencies {}

class MockBookDetailRepository extends Mock implements BookDetailRepository {}

void main() {
  late MockAppDependencies dependencies;
  late MockBookDetailRepository repository;
  late BookDetailViewModel viewModel;

  const testBook = Book(
    workId: 'OL123W',
    title: 'Clean Code',
    authors: ['Robert C. Martin'],
    firstPublishYear: 2008,
    coverId: null,
  );

  setUp(() {
    dependencies = MockAppDependencies();
    repository = MockBookDetailRepository();

    viewModel = BookDetailViewModel(repository: repository);

    when(() => dependencies.createBookDetailViewModel()).thenReturn(viewModel);
  });

  Widget createWidget() {
    return Provider<AppDependencies>.value(
      value: dependencies,
      child: const MaterialApp(home: BookDetailPage(book: testBook)),
    );
  }

  testWidgets('shows loading indicator while book detail is loading', (
    tester,
  ) async {
    final completer = Completer<BookDetail>();

    when(
      () => repository.getBookDetail(workId: 'OL123W'),
    ).thenAnswer((_) => completer.future);

    await tester.pumpWidget(createWidget());

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(
      const BookDetail(
        title: 'Clean Code',
        description: 'A book about writing clean code.',
        subjects: ['Programming'],
      ),
    );

    await tester.pumpAndSettle();
  });

  testWidgets('shows book details when loading succeeds', (tester) async {
    when(() => repository.getBookDetail(workId: 'OL123W')).thenAnswer(
      (_) async => const BookDetail(
        title: 'Clean Code',
        description: 'A book about writing clean code.',
        subjects: ['Programming', 'Software Engineering'],
      ),
    );

    await tester.pumpWidget(createWidget());

    await tester.pumpAndSettle();

    expect(find.text('Robert C. Martin'), findsOneWidget);

    expect(find.text('2008'), findsOneWidget);

    expect(find.text('A book about writing clean code.'), findsOneWidget);

    expect(find.text('Programming'), findsOneWidget);

    expect(find.text('Software Engineering'), findsOneWidget);
  });

  testWidgets('shows error message when book detail loading fails', (
    tester,
  ) async {
    when(
      () => repository.getBookDetail(workId: 'OL123W'),
    ).thenThrow(const BookDetailException('Failed to load book details'));

    await tester.pumpWidget(createWidget());

    await tester.pumpAndSettle();

    expect(find.text('Failed to load book details'), findsOneWidget);
  });
}
