import 'package:bookshelf/network/app_http_client.dart';
import 'package:bookshelf/search/repository/search_repository.dart';
import 'package:bookshelf/search/services/open_library_remote_data_source.dart';
import 'package:bookshelf/search/view_models/search_view_model.dart';
import 'package:bookshelf/search/views/search_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookshelfApp extends StatelessWidget {
  const BookshelfApp({super.key});

  @override
  Widget build(BuildContext context) {
    final httpClient = AppHttpClient();

    final remoteDataSource = OpenLibraryRemoteDataSource(
      httpClient: httpClient,
    );

    final repository = SearchRepository(
      remoteDataSource: remoteDataSource,
      httpClient: httpClient,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bookshelf',
      home: ChangeNotifierProvider(
        create: (_) => SearchViewModel(repository: repository),
        child: const SearchPage(),
      ),
    );
  }
}
