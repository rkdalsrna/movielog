import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../data/services/rating_api_service.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../view_models/my_ratings_view_model.dart';
import '../view_models/learning_member_session.dart';
import '../screens/my/my_ratings_screen.dart';
import '../screens/auth/auth_screen.dart';

import 'package:provider/provider.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/view_models/movie_home_view_model.dart';
import 'package:movielog/view_models/movie_list_view_model.dart';
import 'package:movielog/screens/home/home_screen.dart';
import 'package:movielog/screens/main_screen.dart';
import 'package:movielog/screens/movie/movie_list_screen.dart';
import 'package:movielog/screens/movie_detail_loader.dart';
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
                routes: [
                  GoRoute(
                    path: ':movieId',
                    builder: (context, state) {
                      final id = int.tryParse(
                        state.pathParameters['movieId'] ?? '',
                      );
                      if (id == null || id < 1) {
                        return const Scaffold(
                          body: Center(
                            child: Text('영화 ID가 올바르지 않습니다.'),
                          ),
                        );
                      }
                      final extra = state.extra;
                      return MovieDetailLoader(
                        movieId: id,
                        initialMovie: extra is TmdbMovieDto && extra.id == id
                            ? extra
                            : null,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/my',
                builder: (context, state) => const MyPageScreen(),
                routes: [
                  // 회원가입 성공 콜백은 SignUpViewModel.createdMemberId를 위 세션에 저장합니다.
                  // 6주차 /my/ratings Route의 sampleMemberId만 실제 학습용 회원 ID로 교체합니다.
                  // rootNavigatorKey / parentNavigatorKey는 6주차에서 설정한 그대로 유지합니다.
                  GoRoute(
                    path: 'ratings', // /my Route 아래의 자식, root Navigator에 표시
                    parentNavigatorKey: AppRouter.rootNavigatorKey,
                    builder: (context, state) {
                      final id = context.read<LearningMemberSession>().memberId;
                      if (id == null) {
                        return Scaffold(
                          appBar: AppBar(centerTitle: true, title: const Text('내가 등록한 평점')),
                          body: const Center(child: Text('학습용 회원가입이 필요합니다.')),
                        );
                      }
                      return ChangeNotifierProvider<MyRatingsViewModel>(
                        create: (context) => MyRatingsViewModel(
                          context.read<RatingApiService>(),
                          context.read<TmdbMovieService>(),
                          id,
                        )..load(),
                        child: const MyRatingsScreen(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
