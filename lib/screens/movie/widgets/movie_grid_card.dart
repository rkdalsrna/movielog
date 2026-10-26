import 'package:flutter/material.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/widgets/tmdb_poster_image.dart';
import 'package:movielog/theme/app_colors.dart';

class MovieGridCard extends StatelessWidget {
  const MovieGridCard({
    super.key,
    required this.movie,
    required this.genreNames,
    required this.onTap,
  });

  final TmdbMovieDto movie;
  final Map<int, String> genreNames;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 316.5,
      //카드 전체 영역을 상세 화면 이동용 터치 영역으로 사용
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 256.5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    //포스터 표시 및 이미지 오류 처리
                    TmdbPosterImage(
                      posterPath: movie.posterPath,
                      width: double.infinity,
                      height: 256.5,
                    ),
                    Positioned(
                      //포스터 내부 오른쪽 위에 평점 표시
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 48,
                        height: 24,
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                        decoration: BoxDecoration(
                          color: AppColors.heroOverlay,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 10,
                              color: AppColors.white,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              movie.voteAverage.toStringAsFixed(1),
                              style: const TextStyle(
                                color: AppColors.white,
                                fontFamily: 'Manrope',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
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
              ),
            ),
            const SizedBox(height: 4),
            Text(
              [
                if (movie.releaseDate != null && movie.releaseDate!.length >= 4)
                  movie.releaseDate!.substring(0, 4),
                ...movie.genreIds
                    .map((id) => genreNames[id])
                    .whereType<String>(),
              ].join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
    );
  }
}
