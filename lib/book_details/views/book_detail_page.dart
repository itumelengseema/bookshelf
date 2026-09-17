import 'package:auto_route/auto_route.dart';
import 'package:bookshelf/app/app_dependencies.dart';
import 'package:bookshelf/book_details/view_models/book_detail_state.dart';
import 'package:bookshelf/book_details/view_models/book_detail_view_model.dart';

import 'package:bookshelf/favourites/providers/favourites_provider.dart';

import 'package:bookshelf/search/models/book_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class BookDetailPage extends StatelessWidget {
  final Book book;

  const BookDetailPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final dependencies = context.read<AppDependencies>();

    return ChangeNotifierProvider(
      create: (_) =>
          dependencies.createBookDetailViewModel()
            ..loadBookDetail(workId: book.workId),
      child: _BookDetailView(book: book),
    );
  }
}

class _BookDetailView extends StatelessWidget {
  final Book book;

  const _BookDetailView({required this.book});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BookDetailViewModel>();

    final favouritesProvider = context.watch<FavouritesProvider>();

    final state = viewModel.state;

    final isFavourite = favouritesProvider.isFavourite(book.workId);

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),

        actions: [
          IconButton(
            icon: Icon(isFavourite ? Icons.favorite : Icons.favorite_border),

            onPressed: () {
              favouritesProvider.toggleFavourite(book);
            },
          ),
        ],
      ),

      body: switch (state) {
        BookDetailInitial() => const SizedBox.shrink(),

        BookDetailLoading() => const Center(child: CircularProgressIndicator()),

        BookDetailError(:final message) => Center(child: Text(message)),

        BookDetailLoaded(:final bookDetail) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                const Center(child: Icon(Icons.menu_book_outlined, size: 120)),

              const SizedBox(height: 24),

              Text(
                book.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 8),

              Text(book.authorDisplay),

              const SizedBox(height: 4),

              Text(book.yearDisplay),

              const SizedBox(height: 24),

              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium,
              ),

              const SizedBox(height: 8),

              Text(bookDetail.description),

              const SizedBox(height: 24),

              Text('Subjects', style: Theme.of(context).textTheme.titleMedium),

              const SizedBox(height: 8),

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
      },
    );
  }
}
