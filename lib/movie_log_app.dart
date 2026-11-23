import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/network/movie_log_client.dart';
import 'core/network/tmdb_client.dart';
import 'core/session/auth_session_bridge.dart';
import 'core/session/session_guard.dart';
import 'data/services/favorite_api_service.dart';
import 'data/services/sign_up_service.dart';
import 'data/services/auth_api_service.dart';
import 'data/services/member_api_service.dart';
import 'data/services/rating_api_service.dart';
import 'data/services/tmdb_movie_service.dart';
import 'data/storage/token_storage.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'view_models/learning_member_session.dart';
import 'view_models/auth_view_model.dart';

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tokenStorage = SecureTokenStorage(const FlutterSecureStorage()); //JWT 저장, 조회, 삭제
    final publicClient = createMovieLogClient(); //공개 API 요청
    final authClient = createAuthMovieLogClient(tokenStorage); //인증이 필요한 API 요청

    return MultiProvider(
      providers: [
        Provider<TokenStorage>.value(value: tokenStorage),
        Provider<TmdbMovieService>(
          create: (_) => TmdbMovieService(createTmdbClient()),
        ),
        Provider<RatingApiService>(
          create: (_) => RatingApiService(
            publicClient,
            authClient,
          ),
        ),
        Provider<FavoriteApiService>(
          create: (_) => FavoriteApiService(authClient),
        ),

        // 공개 Client
        Provider<AuthApiService>(
          create: (_) => AuthApiService(publicClient),
        ),
        // 보호 Client (RatingApiService는 공개 조회용 publicClient도 함께 받음)
        Provider<MemberApiService>(
          create: (_) => MemberApiService(authClient),
        ),
        // Service를 주입받는 ViewModel
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(
            context.read<AuthApiService>(),
            context.read<MemberApiService>(),
            context.read<TokenStorage>(),
          ),
        ),
        Provider<AuthSessionBridge>(
          create: (context) {
            final auth = context.read<AuthViewModel>();
            return AuthSessionBridge(
              authSignals: auth,
              sessionVersion: () => auth.sessionVersion,
              verifiedEmail: () => auth.status == AuthStatus.signedIn
                  ? auth.member?.email
                  : null,
            );
          },
          dispose: (_, bridge) => bridge.dispose(),
        ),
        Provider<SessionGuard>(
          create: (context) => context.read<AuthSessionBridge>().guard,
        ),
        ChangeNotifierProvider<LearningMemberSession>(
          create: (_) => LearningMemberSession(),
        ),
        Provider<SignUpService>(
          create: (_) => SignUpService(publicClient),
        ),
      ],
      child: const _MovieLogRouterApp(), // 뒤 절의 Stateful Router 호스트를 사용합니다.
    );
  }
}

//앱이 처음 실행될 때 자동 로그인을 시작하는 역할
class _MovieLogRouterApp extends StatefulWidget {
  const _MovieLogRouterApp();

  @override
  State<_MovieLogRouterApp> createState() => _MovieLogRouterAppState();
}

class _MovieLogRouterAppState extends State<_MovieLogRouterApp> {
  late final GoRouter _router;

  @override
  void initState() { //초기화
    super.initState();

    final authViewModel = context.read<AuthViewModel>(); //AuthViewModel 가져오기

    _router = AppRouter.createRouter(authViewModel); //Router에 전달

    WidgetsBinding.instance.addPostFrameCallback((_) { //첫 번째 화면이 그려진 이후에 작업을 실행
      if (mounted) authViewModel.restoreSession();
    });
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MovieLog',
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
