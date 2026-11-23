import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/screens/movie/widgets/rating_dialog.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/view_models/movie_detail_view_model.dart';
import 'package:movielog/view_models/favorite_detail_view_model.dart';
import 'package:movielog/widgets/favorite_button.dart';
import 'package:movielog/widgets/movielog_button.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<FavoriteDetailViewModel>().load();
    });
  }

  Future<void> _showRatingDialog() async {
    final viewModel = context.read<MovieDetailViewModel>();
    final existing = viewModel.currentRating;
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 저장 중 바깥 탭으로 닫히는 것도 막습니다.
      builder: (_) => RatingDialog(
        initialScore: existing?.score ?? 0,
        initialComment: existing?.comment,
        onSubmit: (score, comment) async {
          if (existing == null) {
            await viewModel.createRating(score: score, comment: comment);
          } else {
            await viewModel.updateRating(score: score, comment: comment);
          }
          if (viewModel.submitStatus != SubmitStatus.success) {
            throw StateError(viewModel.submitMessage ?? '저장에 실패했습니다.');
          }
        },
      ),
    );

    if (!mounted || saved != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(existing == null ? '평점을 등록했어요.' : '평점을 수정했어요.'),
      ),
    );
  }

  Future<void> _deleteRating() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('평점을 삭제할까요?'),
        content: const Text('삭제한 평점은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    final viewModel = context.read<MovieDetailViewModel>();
    await viewModel.deleteRating();
    if (!mounted) return;
    final succeeded = viewModel.submitStatus == SubmitStatus.success;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          succeeded
              ? '평점을 삭제했어요.'
              : viewModel.submitMessage ?? '평점을 삭제하지 못했어요.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MovieDetailViewModel>();
    return _buildMovie(context, viewModel.movie, viewModel);
  }

  Widget _buildMovie(
    BuildContext context,
    TmdbMovieDto movie,
    MovieDetailViewModel viewModel,
  ) {
    return Scaffold(
      // 상세 화면 종료 후 이전 화면으로 이동
      appBar: _DetailAppBar(onBackPressed: () => context.pop()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                movie.posterAsset,
                errorBuilder: (_, error, stackTrace) => const SizedBox(
                  height: 220,
                  child: Center(
                    child: Icon(Icons.image_not_supported_outlined),
                  ),
                ),
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 14),
            _MovieInformation(movie: movie),
            const SizedBox(height: 28),
            _DetailActions(
              onRatingPressed: _showRatingDialog,
              onDeletePressed: viewModel.currentRating == null
                  ? null
                  : _deleteRating,
              hasRating: viewModel.currentRating != null,
            ),
            Consumer<FavoriteDetailViewModel>(
              builder: (context, favorite, _) {
                final message = favorite.errorMessage;
                if (message == null) return const SizedBox.shrink();
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$message 다시 시도해 주세요.',
                    style: const TextStyle(color: AppColors.error),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailAppBar extends AppBar {
  _DetailAppBar({required VoidCallback onBackPressed})
    : super(
        toolbarHeight: 56,
        centerTitle: true,
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
          '영화 상세',
          style: TextStyle(
            color: AppColors.primary,
            fontFamily: 'Manrope',
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

class _MovieInformation extends StatelessWidget {
  const _MovieInformation({required this.movie});

  final TmdbMovieDto movie;

  @override
  Widget build(BuildContext context) {
    // 시놉시스가 없는 영화의 기본 설명 사용
    final synopsis = movie.synopsis.isNotEmpty
        ? movie.synopsis
        : '등록된 줄거리가 없습니다.';

    return Padding(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: const TextStyle(
                        color: AppColors.black,
                        fontFamily: 'Manrope',
                        fontSize: 25,
                        height: 36 / 28,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 13),
                    Text(
                      '${movie.year} · ${movie.genre} · ${movie.runningTime}분',
                      style: const TextStyle(
                        color: AppColors.gray,
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        height: 20 / 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const FavoriteButton(),
            ],
          ),
          const SizedBox(height: 26),
          Text(
            synopsis,
            style: const TextStyle(
              color: AppColors.gray,
              fontFamily: 'Manrope',
              fontSize: 14,
              height: 1.7,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailActions extends StatelessWidget {
  const _DetailActions({
    required this.onRatingPressed,
    required this.onDeletePressed,
    required this.hasRating,
  });

  final VoidCallback onRatingPressed;
  final VoidCallback? onDeletePressed;
  final bool hasRating;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: MovieLogButton(
                width: double.infinity,
                label: hasRating ? '평점 수정' : '평점 남기기',
                onPressed: onRatingPressed,
              ),
            ),
            if (hasRating) ...[
              const SizedBox(width: 8),
              IconButton(
                tooltip: '평점 삭제',
                onPressed: onDeletePressed,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
