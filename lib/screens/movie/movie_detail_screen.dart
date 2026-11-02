import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/screens/movie/widgets/movie_list_loading.dart';
import 'package:movielog/screens/movie/widgets/movie_list_error.dart';
import 'package:movielog/models/movie.dart';
import 'package:movielog/screens/movie/widgets/rating_dialog.dart';
import 'package:movielog/theme/app_colors.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final int? movieId;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Future<Movie?> _movieFuture;

  @override
  void initState() {
    super.initState();
    _loadMovie();
  }

  @override
  void didUpdateWidget(covariant MovieDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.movieId != widget.movieId) {
      _isBookmarked = false;
      _userRating = null;
      _loadMovie();
    }
  }

  //상세 API 요청을 저장해 화면 갱신 시 중복 호출 방지
  void _loadMovie() {
    final id = widget.movieId;
    _movieFuture = id == null
        ? Future<Movie?>.value(null)
        : context.read<TmdbMovieService>().fetchMovieDetail(id);
  }

  // 즐겨찾기 선택 상태
  bool _isBookmarked = false;

  // 사용자가 저장한 별점 상태
  double? _userRating;

  Future<void> _showRatingDialog(Movie movie) async {
    // Dialog가 반환한 별점 대기
    final rating = await showDialog<double>(
      context: context,
      builder: (context) {
        return RatingDialog(
          movieId: movie.id, //상세 조회한 TMDB 영화 ID 전달
          initialRating: _userRating ?? 0,
        );
      },
    );

    // Dialog 취소 시 저장 처리 중단
    if (rating == null || !mounted) return;

    // Dialog에서 반환한 별점을 화면 내부 상태로 저장
    setState(() => _userRating = rating);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${movie.title}에 ${rating.toStringAsFixed(1)}점을 남겼습니다.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Movie?>(
      future: _movieFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: _DetailAppBar(onBackPressed: () => context.pop()),
            body: const MovieListLoading(),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: _DetailAppBar(onBackPressed: () => context.pop()),
            body: MovieListError(onRetry: () => setState(_loadMovie)),
          );
        }
        return _buildMovie(context, snapshot.data);
      },
    );
  }

  Widget _buildMovie(BuildContext context, Movie? movie) {
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
            Image.network(
              movie.posterAsset,
              errorBuilder: (_, error, stackTrace) => const SizedBox(
                height: 585,
                child: Center(child: Icon(Icons.image_not_supported_outlined)),
              ),
              width: double.infinity,
              height: 585,
              fit: BoxFit.cover,
            ),
            _MovieInformation(
              movie: movie,
              //저장한 별점이 없으면 API 평점 표시
              displayedRating: _userRating ?? movie.rating,
            ),
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
        // 평점 버튼 선택 시 Dialog 열기
        onRatingPressed: () => _showRatingDialog(movie),
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
  const _MovieInformation({required this.movie, required this.displayedRating});

  final Movie movie;
  final double displayedRating;

  @override
  Widget build(BuildContext context) {
    // 시놉시스가 없는 영화의 기본 설명 사용
    final synopsis = movie.synopsis.isNotEmpty
        ? movie.synopsis
        : '등록된 줄거리가 없습니다.';

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
          // 사용자가 저장한 별점이 있으면 해당 값으로 갱신
          _RatingSummary(rating: displayedRating),
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
        // 저장된 평점만큼 별 채우기
        RatingBarIndicator(
          rating: rating,
          itemCount: 5,
          itemSize: 16,
          unratedColor: AppColors.disabledButton,
          itemBuilder: (context, index) =>
              const Icon(Icons.star_rounded, color: AppColors.primary),
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
    required this.onRatingPressed,
  });

  final bool isBookmarked;
  final VoidCallback onBookmarkPressed;
  final VoidCallback onRatingPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          color: AppColors.warmWhite,
          border: Border(top: BorderSide(color: AppColors.statCardBorder)),
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
                onPressed: onRatingPressed,
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
