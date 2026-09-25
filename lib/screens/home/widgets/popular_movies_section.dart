import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';

//인기있는 영화 목록
class PopularMoviesSection extends StatelessWidget {
  const PopularMoviesSection({
    super.key,
    required this.onViewAllPressed,
    required this.onMoviePressed,
  });

  final VoidCallback onViewAllPressed;
  final VoidCallback onMoviePressed;

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
                SizedBox(width: 4),
                SizedBox(
                  width: 5,
                  height: 8,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Icon(Icons.chevron_right),
                  ),
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

  final VoidCallback onMoviePressed;

  static const movies = [
    _PopularMovie(
      title: '어비스 워커',
      posterAsset: 'assets/images/posters/poster_abyss_walker.jpg',
      rating: 4.6,
    ),
    _PopularMovie(
      title: '네 번째 오후',
      posterAsset: 'assets/images/posters/poster_fourth_afternoon.jpg',
      rating: 4.2,
    ),
    _PopularMovie(
      title: '밤의 그림자',
      posterAsset: 'assets/images/posters/poster_night_shadows.jpg',
      rating: 4.8,
    ),
    _PopularMovie(
      title: '속삭이는 숲',
      posterAsset: 'assets/images/posters/poster_whispering_woods.jpg',
      rating: 4.4,
    ),
    _PopularMovie(
      title: '공허의 메아리',
      posterAsset: 'assets/images/posters/poster_echoes_of_the_void.jpg',
      rating: 4.1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 256,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _PopularMovieCard(
            movie: movies[index],
            onTap: onMoviePressed,
          );
        },
      ),
    );
  }
}

class _PopularMovieCard extends StatelessWidget {
  const _PopularMovieCard({
    required this.movie,
    required this.onTap,
  });

  final _PopularMovie movie;
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
                child: Image.asset(
                  movie.posterAsset,
                  fit: BoxFit.cover,
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

class _PopularMovie {
  const _PopularMovie({
    required this.title,
    required this.posterAsset,
    required this.rating,
  });

  final String title;
  final String posterAsset;
  final double rating;
}
