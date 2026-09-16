import 'package:auto_route/auto_route.dart';
import 'package:bookshelf/book_details/repository/book_detail_repository.dart';
import 'package:bookshelf/book_details/services/open_library_book_detail_data_source.dart';
import 'package:bookshelf/book_details/view_models/book_detail_state.dart';
import 'package:bookshelf/book_details/view_models/book_detail_view_model.dart';
import 'package:bookshelf/network/app_http_client.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../search/models/book_model.dart';

@RoutePage()
class BookDetailPage extends StatelessWidget {
  final Book book;

  const BookDetailPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final httpClient = AppHttpClient();

    final remoteDataSource = OpenLibraryBookDetailDataSource(
      httpClient: httpClient,
    );

    final repository = BookDetailRepository(remoteDataSource: remoteDataSource);

    return ChangeNotifierProvider(
      create: (_) =>
          BookDetailViewModel(repository: repository)
            ..loadBookDetail(workId: book.workId),
      child: _BookDetailView(book: book),
    );
  }
}

class _BookDetailView extends StatelessWidget {
  const _BookDetailView({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BookDetailViewModel>();
    final state = viewModel.state;

    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: switch (state) {
        BookDetailInitial() => SizedBox.shrink(),
        BookDetailLoading() => Center(child: CircularProgressIndicator()),
        BookDetailError(:final message) => Center(child: Text(message)),
        BookDetailLoaded(:final bookDetail) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (book.coverId != null)
                  Center(
                    child: Image.network(
                      book.coverUrl,
                      height: 280,
                      fit: BoxFit.contain,
                    ),
                  )
                else
                  Center(child: Icon(Icons.menu_book_outlined, size: 120)),

                SizedBox(height: 24),
                Text(
                  book.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 8),
                Text(book.authorDisplay),
                SizedBox(height: 4),
                Text(book.yearDisplay),
                SizedBox(height: 8),
                Text(bookDetail.description),
                SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: bookDetail.subjects
                      .map((subject) => Chip(label: Text(subject)))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      },
    );
  }
}
