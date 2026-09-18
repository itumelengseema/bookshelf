import 'package:auto_route/auto_route.dart';
import 'package:bookshelf/app/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favourites_provider.dart';

@RoutePage()
class FavouritesPage extends StatelessWidget {
  const FavouritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favouritesProvider = context.watch<FavouritesProvider>();

    final favourites = favouritesProvider.favourites;

    return Scaffold(
      appBar: AppBar(title: const Text('Favourites')),
      body: Builder(
        builder: (context) {
          if (favouritesProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (favouritesProvider.errorMessage != null) {
            return Center(child: Text(favouritesProvider.errorMessage!));
          }

          if (favourites.isEmpty) {
            return const Center(child: Text('No favourite books yet'));
          }

          return ListView.builder(
            itemCount: favourites.length,
            itemBuilder: (context, index) {
              final favourite = favourites[index];

              final book = favourite.toBook();

              return ListTile(
                leading: book.coverId == null
                    ? const Icon(Icons.menu_book_outlined, size: 40)
                    : Image.network(
                        book.coverUrl,
                        width: 50,
                        fit: BoxFit.cover,
                      ),

                title: Text(book.title),

                subtitle: Text(
                  '${book.authorDisplay}\n'
                  '${book.yearDisplay}',
                ),

                isThreeLine: true,

                trailing: IconButton(
                  icon: const Icon(Icons.favorite),
                  onPressed: () {
                    favouritesProvider.toggleFavourite(book);
                  },
                ),

                onTap: () {
                  context.router.push(BookDetailRoute(book: book));
                },
              );
            },
          );
        },
      ),
    );
  }
}
