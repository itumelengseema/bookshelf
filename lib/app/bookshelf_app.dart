import 'package:bookshelf/app/app_dependencies.dart';
import 'package:bookshelf/app/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookshelfApp extends StatefulWidget {
  const BookshelfApp({super.key});

  @override
  State<BookshelfApp> createState() => _BookshelfAppState();
}

class _BookshelfAppState extends State<BookshelfApp> {
  late final AppRouter _router;
  late final AppDependencies _dependencies;

  @override
  void initState() {
    super.initState();

    _router = AppRouter();
    _dependencies = AppDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AppDependencies>.value(
      value: _dependencies,

      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => _dependencies.createSearchViewModel(),
          ),

          ChangeNotifierProvider(
            create: (_) =>
                _dependencies.createFavouritesProvider()..loadFavourites(),
          ),
        ],

        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Bookshelf',
          routerConfig: _router.config(),
        ),
      ),
    );
  }
}
