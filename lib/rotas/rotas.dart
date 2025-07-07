import 'package:app_desktop/pages/friends.dart';
import 'package:app_desktop/pages/paginaprincipal.dart';
import 'package:go_router/go_router.dart';

final GoRouter rotasApp = GoRouter(
  initialLocation: '/inicio',
  routes: [
    GoRoute(
      path: '/inicio',
      builder: (context, state) => MainPage(),
    ),
    /*GoRoute(
      path: '/loading',
      builder: (context, state) => LoginPage(),
    ),*/
    GoRoute(
      path: '/friends',
      builder: (context, state) => Friends(),
    ),
  ],
);
