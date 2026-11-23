import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../data/services/rating_api_service.dart';
import '../data/services/member_api_service.dart';
import '../data/services/favorite_api_service.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../core/session/session_guard.dart';
import '../view_models/favorites_view_model.dart';
import '../view_models/favorite_detail_view_model.dart';
import '../view_models/paged_movies_view_model.dart';
import '../view_models/my_ratings_view_model.dart';
import '../view_models/learning_member_session.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/edit_profile_view_model.dart';
import '../screens/my/my_ratings_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/movie_search_screen.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/login_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../widgets/movielog_button.dart';

import 'package:provider/provider.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/view_models/movie_home_view_model.dart';
import 'package:movielog/view_models/movie_list_view_model.dart';
import 'package:movielog/screens/home/home_screen.dart';
import 'package:movielog/screens/main_screen.dart';
import 'package:movielog/screens/movie/movie_list_screen.dart';
import 'package:movielog/screens/movie/movie_detail_loader.dart';
import 'package:movielog/screens/my/my_page_screen.dart';

String? authRedirect(AuthStatus status, String location) {
  const publicPaths = {'/login', '/register'};
  final atStart = location == '/start';
  final atPublic = publicPaths.contains(location);

  return switch (status) {
    // 토큰 확인 중 또는 확인 실패(재시도 버튼): 스플래시 화면 유지
    AuthStatus.initializing ||
    AuthStatus.retryRequired =>
      atStart ? null : '/start',
    // 로그아웃 또는 로그인 요청 중: 공개 화면만 허용
    AuthStatus.signedOut ||
    AuthStatus.authenticating =>
      atPublic ? null : '/login',
    // 로그인됨: 스플래시와 로그인·회원가입 화면은 홈으로 보냄
    AuthStatus.signedIn => (atStart || atPublic) ? '/home' : null,
  };
}

class AppRouter {
  AppRouter._();

  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(AuthViewModel authViewModel) {
    return GoRouter(
      initialLocation: '/start',
      navigatorKey: rootNavigatorKey,
      refreshListenable: authViewModel, //// 인증 상태가 바뀌면 redirect를 다시 실행
      redirect: (context, state) {
        return authRedirect(authViewModel.status, state.uri.path);
      },
      routes: [
      GoRoute(
        path: '/start',
        builder: (context, state) {
          final auth = context.watch<AuthViewModel>();
          return SplashScreen(
            message: auth.message,
            onRetry: auth.status == AuthStatus.retryRequired
                ? auth.restoreSession
                : null,
          );
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
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
                  return MultiProvider(
                    providers: [
                      ChangeNotifierProvider<MovieListViewModel>(
                        create: (context) => MovieListViewModel(
                          context.read<TmdbMovieService>(),
                        ),
                      ),
                      ChangeNotifierProvider<PagedMoviesViewModel>(
                        create: (context) => PagedMoviesViewModel(
                          tmdbApi: context.read<TmdbMovieService>(),
                        ),
                      ),
                    ],
                    child: MovieListScreen(
                      initialGenresQuery: state.uri.queryParameters['genre'],
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'search',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => ChangeNotifierProvider(
                      create: (_) => PagedMoviesViewModel(
                        tmdbApi: context.read<TmdbMovieService>(),
                      ),
                      child: MovieSearchScreen(
                        onOpenMovie: (movie) async {
                          await context.push(
                            '/movies/${movie.id}',
                            extra: movie,
                          );
                        },
                      ),
                    ),
                  ),
                  GoRoute(
                    path: ':movieId',
                    parentNavigatorKey: rootNavigatorKey,
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
                      final auth = context.watch<AuthViewModel>();
                      final member = auth.member;
                      final guard = context.read<SessionGuard>();
                      if (member == null || guard.accountId != member.email) {
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final extra = state.extra;
                      return ChangeNotifierProvider(
                        key: ValueKey('${member.email}:${guard.generation}'),
                        create: (_) => FavoriteDetailViewModel(
                          movieId: id,
                          favoriteApi: context.read<FavoriteApiService>(),
                          sessionGuard: guard,
                          accountId: member.email,
                          auth: auth,
                        ),
                        child: MovieDetailLoader(
                          movieId: id,
                          initialMovie: extra is TmdbMovieDto && extra.id == id
                              ? extra
                              : null,
                        ),
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
                  GoRoute(
                    path: 'profile/edit',
                    parentNavigatorKey: AppRouter.rootNavigatorKey,
                    builder: (context, state) {
                      final auth = context.watch<AuthViewModel>();
                      if (auth.member == null) {
                        return Scaffold(
                          appBar: AppBar(
                            centerTitle: true,
                            title: const Text('프로필 수정'),
                          ),
                          body: Center(
                            child: auth.memberStatus == MemberLoadStatus.error
                                ? MovieLogButton(
                                    label: '다시 시도',
                                    onPressed: () =>
                                        auth.loadMember(force: true),
                                  )
                                : const CircularProgressIndicator(),
                          ),
                        );
                      }
                      return ChangeNotifierProvider<EditProfileViewModel>(
                        create: (context) => EditProfileViewModel(
                          context.read<MemberApiService>(),
                          auth,
                        ),
                        child: const EditProfileScreen(),
                      );
                    },
                  ),
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
                          context.read<AuthViewModel>(),
                          id,
                        )..load(),
                        child: const MyRatingsScreen(),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'favorites',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final auth = context.watch<AuthViewModel>();
                      final member = auth.member;
                      final guard = context.read<SessionGuard>();
                      if (member == null) {
                        return Scaffold(
                          appBar: AppBar(
                            title: const Text('내 즐겨찾기'),
                            centerTitle: true,
                          ),
                          body: Center(
                            child: auth.memberStatus == MemberLoadStatus.error
                                ? FilledButton(
                                    onPressed: auth.loadMember,
                                    child: const Text('내 정보 다시 조회'),
                                  )
                                : const CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (guard.accountId != member.email) {
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return ChangeNotifierProvider(
                        key: ValueKey(
                          '${member.email}:${guard.generation}',
                        ),
                        create: (_) => FavoritesViewModel(
                          favoriteApi: context.read<FavoriteApiService>(),
                          tmdbApi: context.read<TmdbMovieService>(),
                          sessionGuard: guard,
                          accountId: member.email,
                          auth: auth,
                        ),
                        child: FavoritesScreen(
                          onOpenMovie: (movie) async {
                            await context.push(
                              '/movies/${movie.id}',
                              extra: movie,
                            );
                          },
                        ),
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
}
