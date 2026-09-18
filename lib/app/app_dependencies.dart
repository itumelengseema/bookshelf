import '../core/database/app_database.dart';
import '../core/network/app_http_client.dart';
import '../features/book_details/data/datasources/open_library_book_detail_data_source.dart';
import '../features/book_details/data/repositories/book_detail_repository_impl.dart';
import '../features/book_details/domain/repositories/book_detail_repository.dart';
import '../features/book_details/presentation/view_models/book_detail_view_model.dart';
import '../features/favourites/data/datasources/favourites_local_data_source.dart';
import '../features/favourites/data/repositories/favourites_repository.dart';
import '../features/favourites/domain/repositories/favourites_repository.dart';
import '../features/favourites/presentation/providers/favourites_provider.dart';
import '../features/search/data/datasources/open_library_remote_data_source.dart';
import '../features/search/data/datasources/search_cache_data_source.dart';
import '../features/search/data/repositories/search_repository.dart';
import '../features/search/domain/repositories/search_repository.dart';
import '../features/search/presentation/view_models/search_view_model.dart';

class AppDependencies {
  final AppHttpClient httpClient;

  late final AppDatabase appDatabase;

  late final SearchRepository searchRepository;

  late final BookDetailRepository bookDetailRepository;

  late final FavouritesRepository favouritesRepository;

  AppDependencies() : httpClient = AppHttpClient() {
    appDatabase = AppDatabase();

    final searchRemoteDataSource = OpenLibraryRemoteDataSource(
      httpClient: httpClient,
    );

    final searchCacheDataSource = SqliteSearchCacheDataSource(
      appDatabase: appDatabase,
    );

    searchRepository = SearchRepositoryImpl(
      remoteDataSource: searchRemoteDataSource,
      cacheDataSource: searchCacheDataSource,
    );

    final bookDetailRemoteDataSource = OpenLibraryBookDetailDataSource(
      httpClient: httpClient,
    );

    bookDetailRepository = BookDetailRepositoryImpl(
      remoteDataSource: bookDetailRemoteDataSource,
    );

    final favouritesLocalDataSource = SqliteFavouritesLocalDataSource(
      appDatabase: appDatabase,
    );

    favouritesRepository = FavouritesRepositoryImpl(
      localDataSource: favouritesLocalDataSource,
    );
  }

  SearchViewModel createSearchViewModel() {
    return SearchViewModel(repository: searchRepository);
  }

  BookDetailViewModel createBookDetailViewModel() {
    return BookDetailViewModel(repository: bookDetailRepository);
  }

  FavouritesProvider createFavouritesProvider() {
    return FavouritesProvider(repository: favouritesRepository);
  }
}
