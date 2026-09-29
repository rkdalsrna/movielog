import 'package:flutter/material.dart';
import 'package:movielog/data/mock_movies.dart';
import 'package:movielog/models/movie.dart';
import 'package:movielog/theme/app_colors.dart';

// 인기 영화 목록
class PopularMoviesSection extends StatelessWidget {
  const PopularMoviesSection({
    super.key,
    required this.onViewAllPressed,
    required this.onMoviePressed,
  });

  final VoidCallback onViewAllPressed;
  final ValueChanged<Movie> onMoviePressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 324,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PopularMoviesHeader(onViewAllPressed: onViewAllPressed),
            const SizedBox(height: 10),
            _PopularMovieList(onMoviePressed: onMoviePressed),
          ],
        ),
      ),
    );
  }
}

class _PopularMoviesHeader extends StatelessWidget {
  const _PopularMoviesHeader({required this.onViewAllPressed});

  final VoidCallback onViewAllPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '인기 영화',
            style: TextStyle(
              color: AppColors.black,
              fontFamily: 'Manrope',
              fontSize: 22,
              height: 1.3,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.5,
            ),
          ),
          TextButton(
            onPressed: onViewAllPressed,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '전체보기',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PopularMovieList extends StatelessWidget {
  const _PopularMovieList({required this.onMoviePressed});

  final ValueChanged<Movie> onMoviePressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 256,
      // 인기 영화를 가로로 스크롤할 수 있게 배치
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: popularMovies.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _PopularMovieCard(
            // 목록의 순서를 포스터 순위로 사용
            rank: index + 1,
            movie: popularMovies[index],
            onTap: () => onMoviePressed(popularMovies[index]),
          );
        },
      ),
    );
  }
}

class _PopularMovieCard extends StatelessWidget {
  const _PopularMovieCard({
    required this.rank,
    required this.movie,
    required this.onTap,
  });

  final int rank;
  final Movie movie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 256,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                width: 140,
                height: 200,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      movie.posterAsset,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      // 순위 라벨을 포스터 내부 왼쪽 위에 배치
                      top: 8,
                      left: 8,
                      child: Container(
                        width: 25,
                        height: 26,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                        decoration: BoxDecoration(
                          color: AppColors.heroOverlay,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.rankingBadgeBorder,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '$rank',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            height: 16 / 12,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.black,
                fontFamily: 'Manrope',
                fontSize: 16,
                height: 20 / 16,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 16,
              child: Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 12,
                    color: AppColors.ratingStar,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    movie.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppColors.gray,
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: FontWeight.w400,
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
