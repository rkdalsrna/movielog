import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/screens/home/widgets/featured_movie_section.dart';
import 'package:movielog/screens/home/widgets/popular_movies_section.dart';
import 'package:movielog/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HomeHeader(
              onSearchPressed: () => context.go('/movies'),
            ),
            const _QuestionHeader(),
            const FeaturedMovieSection(),
            PopularMoviesSection(
              onViewAllPressed: () => context.go('/movies'),
              onMoviePressed: () => context.go('/movies'),
            ),
          ],
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
