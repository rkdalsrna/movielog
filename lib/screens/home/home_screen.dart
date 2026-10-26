import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:movielog/view_models/movie_home_view_model.dart';
import 'package:movielog/screens/movie/widgets/movie_list_loading.dart';
import 'package:movielog/screens/movie/widgets/movie_list_error.dart';
import 'package:movielog/screens/movie/widgets/movie_list_empty.dart';
import 'package:movielog/screens/home/widgets/featured_movie_section.dart';
import 'package:movielog/screens/home/widgets/popular_movies_section.dart';
import 'package:movielog/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 홈 화면 전체를 스크롤할 수 있도록 각 섹션을 세로로 배치
    return SafeArea(
      bottom: false,
      //아래로 당기면 인기 영화 다시 조회
      child: RefreshIndicator(
        onRefresh: () => context.read<MovieHomeViewModel>().loadPopular(),
        child: SingleChildScrollView(
          //내용이 짧아도 당겨서 새로고침 가능
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeHeader(
                // 검색 버튼을 누르면 영화 목록 탭으로 이동
                onSearchPressed: () => context.go('/movies'),
              ),
              const _QuestionHeader(),
              //실제 인기 영화 요청 상태에 따라 홈 콘텐츠 표시
              Consumer<MovieHomeViewModel>(
                builder: (context, viewModel, child) {
                  return switch (viewModel.status) {
                    MovieHomeLoadStatus.idle || MovieHomeLoadStatus.loading =>
                      const SizedBox(height: 300, child: MovieListLoading()),
                    MovieHomeLoadStatus.error => MovieListError(
                      message: viewModel.message,
                      onRetry: viewModel.loadPopular,
                    ),
                    MovieHomeLoadStatus.empty => const MovieListEmpty(),
                    MovieHomeLoadStatus.success => Column(
                      children: [
                        FeaturedMovieSection(
                          movie: viewModel
                              .popularMovies
                              .first, //TMDB 인기 영화 목록의 첫 번째 영화
                          onDetailPressed: () => context.push(
                            '/movies/${viewModel.popularMovies.first.id}',
                          ),
                        ),
                        PopularMoviesSection(
                          movies: viewModel.popularMovies,
                          onViewAllPressed: () => context.go('/movies'),
                          onMoviePressed: (movie) =>
                              context.push('/movies/${movie.id}'),
                        ),
                      ],
                    ),
                  };
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onSearchPressed});

  final VoidCallback onSearchPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'MovieLog',
              style: TextStyle(
                color: AppColors.primary,
                fontFamily: 'Manrope',
                fontSize: 22,
                height: 1.2,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.55,
              ),
            ),
            IconButton(
              onPressed: onSearchPressed,
              tooltip: '영화 검색',
              icon: SvgPicture.asset(
                'assets/icons/search.svg',
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionHeader extends StatelessWidget {
  const _QuestionHeader();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      height: 104,
      child: Padding(
        padding: EdgeInsets.only(top: 16, left: 16, bottom: 16),
        child: Text(
          '오늘은 어떤\n영화를 볼까요?',
          style: TextStyle(
            color: AppColors.black,
            fontFamily: 'Manrope',
            fontSize: 28,
            height: 1.2,
            fontWeight: FontWeight.w500,
            letterSpacing: -1,
          ),
        ),
      ),
    );
  }
}
