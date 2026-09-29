import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movielog/data/mock_movies.dart';
import 'package:movielog/theme/app_colors.dart';

// 추천 메인 영화
class FeaturedMovieSection extends StatelessWidget {
  const FeaturedMovieSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      height: 558,
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 24),
        child: _FeaturedMovieCard(),
      ),
    );
  }
}

class _FeaturedMovieCard extends StatelessWidget {
  const _FeaturedMovieCard();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 534,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        // 포스터 위에 오버레이와 영화 정보를 겹쳐 표시
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              featuredMovie.posterAsset,
              fit: BoxFit.cover,
            ),
            // 흰색 글자가 잘 보이도록 포스터 전체를 어둡게 처리
            const ColoredBox(color: AppColors.heroOverlay),
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _RecommendationBadge(),
                  const SizedBox(height: 8),
                  Text(
                    featuredMovie.title,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      color: AppColors.white,
                      fontSize: 28,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${featuredMovie.genre} · ${featuredMovie.runningTime}분',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      color: AppColors.white,
                      fontSize: 16,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      icon: SvgPicture.asset(
                        'assets/icons/info.svg',
                        width: 17,
                        height: 17,
                        colorFilter: const ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: const Text(
                        '상세보기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationBadge extends StatelessWidget {
  const _RecommendationBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.profileImageBorder),
      ),
      child: const Text(
        '추천 신작',
        style: TextStyle(
          fontFamily: 'Manrope',
          color: AppColors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
