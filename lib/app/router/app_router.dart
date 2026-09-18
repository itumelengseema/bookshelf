import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import '../../core/domain/entities/book.dart';
import '../../features/book_details/presentation/views/book_detail_page.dart';
import '../../features/favourites/presentation/views/favourites_page.dart';
import '../../features/search/presentation/views/search_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SearchRoute.page, initial: true),
    AutoRoute(page: BookDetailRoute.page),
    AutoRoute(page: FavouritesRoute.page),
  ];
}
