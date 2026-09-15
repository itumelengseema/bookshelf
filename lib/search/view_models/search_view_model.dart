import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:bookshelf/search/repository/search_repository.dart';
import 'package:bookshelf/search/view_models/search_state.dart';

class SearchViewModel extends ChangeNotifier {
  final SearchRepository repository;

  SearchViewModel({required this.repository});

  SearchState _state = const SearchInitial();

  SearchState get state => _state;

  Timer? _debounce;

  Future<void> search(String query) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      _state = const SearchInitial();
      notifyListeners();
      return;
    }

    _state = const SearchLoading();
    notifyListeners();

    try {
      final result = await repository.searchBooks(query: trimmedQuery, page: 1);

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

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
