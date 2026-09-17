import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';

import '../../book_details/views/book_detail_page.dart';
import '../../favourites/views/favourites_page.dart';
import '../../search/models/book_model.dart';
import '../../search/views/search_page.dart';

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
