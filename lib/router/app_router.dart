import 'package:go_router/go_router.dart';
import 'package:movielog/screens/home/home_screen.dart';
import 'package:movielog/screens/main_screen.dart';
import 'package:movielog/screens/movie/movie_list_screen.dart';
import 'package:movielog/screens/movie/movie_detail_screen.dart';
import 'package:movielog/screens/my_page_screen.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainScreen(
            currentIndex: indexFromLocation(state.uri.path),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/movies',
            builder: (context, state) => const MovieListScreen(),
          ),
          GoRoute(
            path: '/my',
            builder: (context, state) => const MyPageScreen(),
          ),
        ],
      ),
      // ShellRoute 밖에 상세 Route를 배치해 하단 네비게이션 숨김
      GoRoute(
        path: '/movies/:movieId',
        builder: (context, state) {
          // Path Parameter를 정수 ID로 변환해 상세 화면에 전달
          return MovieDetailScreen(
            movieId: int.tryParse(state.pathParameters['movieId'] ?? ''),
          );
        },
      ),
    ],
  );

  static int indexFromLocation(String path) {
    if (path.startsWith('/movies')) return 1;
    if (path.startsWith('/my')) return 2;
    return 0;
  }
}
