import 'package:bookshelf/book_details/repository/book_detail_repository.dart';
import 'package:bookshelf/book_details/services/open_library_book_detail_data_source.dart';
import 'package:bookshelf/book_details/view_models/book_detail_view_model.dart';
import 'package:bookshelf/network/app_http_client.dart';
import 'package:bookshelf/search/repository/search_repository.dart';
import 'package:bookshelf/search/services/open_library_remote_data_source.dart';
import 'package:bookshelf/search/view_models/search_view_model.dart';

class AppDependencies {
  final AppHttpClient httpClient;

  late final SearchRepository searchRepository;
  late final BookDetailRepository bookDetailRepository;

  AppDependencies() : httpClient = AppHttpClient() {
    final searchRemoteDataSource = OpenLibraryRemoteDataSource(
      httpClient: httpClient,
    );

    final bookDetailRemoteDataSource = OpenLibraryBookDetailDataSource(
      httpClient: httpClient,
    );

    searchRepository = SearchRepository(
      remoteDataSource: searchRemoteDataSource,
      httpClient: httpClient,
    );

    bookDetailRepository = BookDetailRepository(
      remoteDataSource: bookDetailRemoteDataSource,
    );
  }

  SearchViewModel createSearchViewModel() {
    return SearchViewModel(repository: searchRepository);
  }

  BookDetailViewModel createBookDetailViewModel() {
    return BookDetailViewModel(repository: bookDetailRepository);
  }
}
