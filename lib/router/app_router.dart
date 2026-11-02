import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../data/services/rating_api_service.dart';
import '../view_models/my_ratings_view_model.dart';
import '../screens/my/my_ratings_screen.dart';
import '../screens/auth/auth_screen.dart';

import 'package:provider/provider.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/view_models/movie_home_view_model.dart';
import 'package:movielog/view_models/movie_list_view_model.dart';
import 'package:movielog/screens/home/home_screen.dart';
import 'package:movielog/screens/main_screen.dart';
import 'package:movielog/screens/movie/movie_list_screen.dart';
import 'package:movielog/screens/movie/movie_detail_screen.dart';
import 'package:movielog/screens/my/my_page_screen.dart';

class AppRouter {
  AppRouter._();

  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    initialLocation: '/home',
    navigatorKey: rootNavigatorKey,
    routes: [
      // 중복 확인 테스트를 위한 임시 인증 화면 진입 경로
      GoRoute(
        path: '/register',
        builder: (context, state) => const AuthScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) =>
                    ChangeNotifierProvider<MovieHomeViewModel>(
                      //공통 서비스를 주입하고 인기 영화 초기 조회
                      //하위 화면에서 ViewModel을 처음 읽을 때 생성
                      create: (context) =>
                          MovieHomeViewModel(context.read<TmdbMovieService>())
                            ..loadPopular(),
                      //홈 화면 하위에 ViewModel 제공
                      child: const HomeScreen(),
                    ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/movies',
                builder: (context, state) {
                  return ChangeNotifierProvider<MovieListViewModel>(
                    //공통 서비스를 주입하고 초기 조회는 화면에서 장르 복원 후 실행
                    create: (context) =>
                        MovieListViewModel(context.read<TmdbMovieService>()),
                    //Query Parameter의 장르를 영화 목록 화면에 전달
                    child: MovieListScreen(
                      initialGenresQuery: state.uri.queryParameters['genre'],
                    ),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/my',
                builder: (context, state) => const MyPageScreen(),
                routes: [
                  GoRoute(
                    path: 'ratings',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) =>
                        ChangeNotifierProvider<MyRatingsViewModel>(
                          create: (context) => MyRatingsViewModel(
                            context.read<RatingApiService>(),
                            context.read<TmdbMovieService>(),
                            sampleMemberId,
                          )..load(),
                          child: const MyRatingsScreen(),
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      //ShellRoute 밖에 상세 Route를 배치해 하단 네비게이션 숨김
      GoRoute(
        path: '/movies/:movieId',
        builder: (context, state) {
          //Path Parameter를 정수 ID로 변환해 상세 화면에 전달
          return MovieDetailScreen(
            movieId: int.tryParse(state.pathParameters['movieId'] ?? ''),
          );
        },
      ),
    ],
  );
}
