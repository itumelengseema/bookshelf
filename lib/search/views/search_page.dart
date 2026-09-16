import 'package:auto_route/auto_route.dart';
import 'package:bookshelf/app/router/app_router.dart';
import 'package:bookshelf/search/view_models/search_state.dart';
import 'package:bookshelf/search/view_models/search_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SearchViewModel>();
    final state = viewModel.state;

    return Scaffold(
      appBar: AppBar(title: const Text('Bookshelf')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: viewModel.onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search books',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: switch (state) {
              SearchInitial() => const _InitialState(),

              SearchLoading() => const Center(
                child: CircularProgressIndicator(),
              ),

              SearchEmpty() => const Center(child: Text('No books found')),

              SearchError(:final message) => Center(child: Text(message)),

              SearchResults(:final books, :final isLoadingMore) => _ResultsList(
                books: books,
                isLoadingMore: isLoadingMore,
                onLoadMore: viewModel.loadMore,
              ),
            },
          ),
        ],
      ),
    );
  }
}

class _InitialState extends StatelessWidget {
  const _InitialState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Search for a book to get started'));
  }
}

class _ResultsList extends StatelessWidget {
  final List<dynamic> books;
  final bool isLoadingMore;
  final Future<void> Function() onLoadMore;

  const _ResultsList({
    required this.books,
    required this.isLoadingMore,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 200) {
          onLoadMore();
        }

        return false;
      },
      child: ListView.builder(
        itemCount: books.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == books.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final book = books[index];

          return ListTile(
            leading: book.coverId == null
                ? const Icon(Icons.menu_book_outlined, size: 40)
                : Image.network(book.coverUrl, width: 50, fit: BoxFit.cover),
            title: Text(book.title),
            subtitle: Text('${book.authorDisplay}\n${book.yearDisplay}'),
            isThreeLine: true,
            onTap: () {
              context.router.push(BookDetailRoute(book: book));
            },
            trailing: IconButton(
              onPressed: () {
                // Favourite functionality later.
              },
              icon: const Icon(Icons.favorite_border),
            ),
          );
        },
      ),
    );
  }
}
