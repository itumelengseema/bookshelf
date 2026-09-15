import 'package:bookshelf/app/router/app_router.dart';
import 'package:bookshelf/network/app_http_client.dart';
import 'package:bookshelf/search/repository/search_repository.dart';
import 'package:bookshelf/search/services/open_library_remote_data_source.dart';
import 'package:bookshelf/search/view_models/search_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookshelfApp extends StatefulWidget {
  const BookshelfApp({super.key});

  @override
  State<BookshelfApp> createState() => _BookshelfAppState();
}

class _BookshelfAppState extends State<BookshelfApp> {
  late final AppRouter _router;

  late final AppHttpClient _httpClient;
  late final OpenLibraryRemoteDataSource _remoteDataSource;
  late final SearchRepository _searchRepository;

  @override
  void initState() {
    super.initState();

    _router = AppRouter();

    _httpClient = AppHttpClient();

    _remoteDataSource = OpenLibraryRemoteDataSource(httpClient: _httpClient);

    _searchRepository = SearchRepository(
      remoteDataSource: _remoteDataSource,
      httpClient: _httpClient,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchViewModel(repository: _searchRepository),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Bookshelf',
        routerConfig: _router.config(),
      ),
    );
  }
}
