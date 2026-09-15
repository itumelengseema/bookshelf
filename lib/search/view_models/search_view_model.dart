import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:bookshelf/search/repository/search_repository.dart';
import 'package:bookshelf/search/view_models/search_state.dart';

class SearchViewModel extends ChangeNotifier {
  final SearchRepository repository;

  SearchViewModel({required this.repository});

  SearchState _state = const SearchInitial();

  SearchState get state => _state;

  String _currentQuery = '';
  int _currentPage = 1;
  int _totalResults = 0;
  bool _isLoadingMore = false;

  Timer? _debounce;

  Future<void> search(String query) async {
    final trimmedQuery = query.trim();

    _currentQuery = trimmedQuery;
    _currentPage = 1;
    _totalResults = 0;
    _isLoadingMore = false;

    if (trimmedQuery.isEmpty) {
      _state = const SearchInitial();
      notifyListeners();
      return;
    }

    _state = const SearchLoading();
    notifyListeners();

    try {
      final result = await repository.searchBooks(query: trimmedQuery, page: 1);

      _totalResults = result.totalResults;

      if (result.books.isEmpty) {
        _state = const SearchEmpty();
      } else {
        _state = SearchResults(books: result.books);
      }
    } on SearchException catch (error) {
      _state = SearchError(error.message);
    } catch (_) {
      _state = const SearchError('Something went wrong.');
    }

    notifyListeners();
  }

  void onSearchChanged(String query) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 450), () {
      search(query);
    });
  }

  Future<void> loadMore() async {
    final currentState = _state;

    if (currentState is! SearchResults) {
      return;
    }

    if (_isLoadingMore) {
      return;
    }

    if (currentState.books.length >= _totalResults) {
      return;
    }

    _isLoadingMore = true;

    _state = SearchResults(books: currentState.books, isLoadingMore: true);

    notifyListeners();

    try {
      final nextPage = _currentPage + 1;

      final result = await repository.searchBooks(
        query: _currentQuery,
        page: nextPage,
      );

      _currentPage = nextPage;

      _state = SearchResults(books: [...currentState.books, ...result.books]);
    } on SearchException {
      _state = SearchResults(books: currentState.books);
    } catch (_) {
      _state = SearchResults(books: currentState.books);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  @visibleForTesting
  void debugSetState(SearchState state) {
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
