import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/data/mock_movies.dart';
import 'package:movielog/models/movie.dart';
import 'package:movielog/theme/app_colors.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({
    super.key,
    required this.movieId,
  });

  final int? movieId;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  // 즐겨찾기 선택 상태
  bool _isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    // Route로 전달받은 ID에 해당하는 영화 조회
    final movie = findMovieById(widget.movieId);

    // 일치하는 영화가 없을 때 예외 화면 표시
    if (movie == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: const Center(child: Text('영화를 찾을 수 없습니다.')),
      );
    }

    return Scaffold(
      // 상세 화면 종료 후 이전 화면으로 이동
      appBar: _DetailAppBar(onBackPressed: () => context.pop()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              movie.posterAsset,
              width: double.infinity,
              height: 585,
              fit: BoxFit.cover,
            ),
            _MovieInformation(movie: movie),
          ],
        ),
      ),
      bottomNavigationBar: _DetailActions(
        isBookmarked: _isBookmarked,
        onBookmarkPressed: () {
          // 즐겨찾기 선택 상태 전환
          setState(() => _isBookmarked = !_isBookmarked);

          ScaffoldMessenger.of(context).showSnackBar(
            // 즐겨찾기 변경 결과 안내
            SnackBar(
              content: Text(
                _isBookmarked
                    ? '${movie.title}을 즐겨찾기에 추가했습니다.'
                    : '${movie.title}을 즐겨찾기에서 삭제했습니다.',
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DetailAppBar extends AppBar {
  _DetailAppBar({required VoidCallback onBackPressed})
      : super(
          toolbarHeight: 56,
          leading: IconButton(
            onPressed: onBackPressed,
            icon: SvgPicture.asset(
              'assets/icons/arrow_back.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
          ),
          title: const Text(
            'Cinema Archive',
            style: TextStyle(
              color: AppColors.primary,
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: SvgPicture.asset(
                'assets/icons/share.svg',
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  AppColors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        );
}

class _MovieInformation extends StatelessWidget {
  const _MovieInformation({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    // 시놉시스가 없는 영화의 기본 설명 사용
    final synopsis = movie.synopsis.isNotEmpty
        ? movie.synopsis
        : '영화 속 인물들이 서로의 상처를 이해하며 새로운 여정을 시작하는 이야기입니다.';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            movie.title,
            style: const TextStyle(
              color: AppColors.black,
              fontFamily: 'Manrope',
              fontSize: 28,
              height: 36 / 28,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.normal,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${movie.year} · ${movie.genre} · ${movie.runningTime}분',
            style: const TextStyle(
              color: AppColors.gray,
              fontFamily: 'Manrope',
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
              letterSpacing: 0.25,
            ),
          ),
          const SizedBox(height: 12),
          _RatingSummary(rating: movie.rating),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            // 여러 장르를 분리해 각각의 칩으로 표시
            children: movie.genre
                .split(' · ')
                .map((genre) => _GenreTag(label: genre))
                .toList(),
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.statCardBorder),
          const SizedBox(height: 16),
          const Text(
            '시놉시스',
            style: TextStyle(
              color: AppColors.black,
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            synopsis,
            style: const TextStyle(
              color: AppColors.black,
              fontFamily: 'Manrope',
              fontSize: 14,
              height: 1.65,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingSummary extends StatelessWidget {
  const _RatingSummary({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 영화 평점을 별 다섯 개와 숫자로 표시
        ...List.generate(
          5,
          (index) => const Icon(
            Icons.star_rounded,
            size: 16,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            color: AppColors.black,
            fontFamily: 'Manrope',
            fontSize: 16,
            height: 24 / 16,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            letterSpacing: 0.15,
          ),
        ),
        const SizedBox(width: 4),
        const Text(
          '(1,245)',
          style: const TextStyle(
            color: AppColors.gray,
            fontFamily: 'Manrope',
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            letterSpacing: 0.25,
          ),
        ),
      ],
    );
  }
}

class _GenreTag extends StatelessWidget {
  const _GenreTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.statCardBackground,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.gray,
          fontFamily: 'Manrope',
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _DetailActions extends StatelessWidget {
  const _DetailActions({
    required this.isBookmarked,
    required this.onBookmarkPressed,
  });

  final bool isBookmarked;
  final VoidCallback onBookmarkPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          color: AppColors.warmWhite,
          border: Border(
            top: BorderSide(color: AppColors.statCardBorder),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                // 즐겨찾기 상태 변경 요청
                onPressed: onBookmarkPressed,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
                icon: SizedBox(
                  width: 14,
                  height: 18,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                label: const Text('즐겨찾기'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.rate_review_outlined, size: 20),
                label: const Text('평점 남기기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
