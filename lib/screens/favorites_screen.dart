import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../view_models/favorites_view_model.dart';
import '../view_models/load_phase.dart';
import '../theme/app_colors.dart';
import '../widgets/movielog_button.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({
    super.key,
    required this.onOpenMovie,
  });

  final Future<void> Function(TmdbMovieDto movie) onOpenMovie;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<FavoritesViewModel>().refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('내 즐겨찾기'),
      centerTitle: true,
    ),
    body: Consumer<FavoritesViewModel>(
      builder: (context, vm, _) {
        if (vm.phase == LoadPhase.idle ||
            vm.phase == LoadPhase.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (vm.phase == LoadPhase.empty) {
          return const _FavoritesEmptyView();
        }

        if (vm.phase == LoadPhase.error) {
          return _FavoritesErrorView(
            message: vm.errorMessage ?? '즐겨찾기를 불러오지 못했습니다.',
            onRetry: vm.refresh,
          );
        }

        return RefreshIndicator(
          onRefresh: vm.refresh,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: vm.items.length,
            itemBuilder: (context, index) {
              final item = vm.items[index], movie = item.movie;

              if (movie == null) {
                return ListTile(
                  leading: const Icon(Icons.broken_image_outlined),
                  title: Text('TMDB #${item.favorite.movieId}'),
                  subtitle: Text(item.errorMessage ?? '정보가 없습니다.'),
                  trailing: MovieLogButton(
                    width: 110,
                    label: '정보 재조회',
                    onPressed: vm.refresh,
                  ),
                );
              }

              return _FavoriteMovieCard(
                movie: movie,
                onTap: () async {
                  await widget.onOpenMovie(movie);
                  if (!mounted) return;
                  await vm.refresh();
                },
              );
            },
          ),
        );
      },
    ),
  );
}

class _FavoritesEmptyView extends StatelessWidget {
  const _FavoritesEmptyView();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment(0, -0.28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 25,
            child: FittedBox(
              fit: BoxFit.fill,
              child: Icon(
                Icons.bookmark_border,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(height: 45),
          Text(
            '아직 즐겨찾기한 영화가 없습니다.',
            style: TextStyle(
              color: AppColors.gray,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 14),
          Text(
            '영화 상세에서 북마크를 눌러보세요.',
            style: TextStyle(color: AppColors.gray, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _FavoritesErrorView extends StatelessWidget {
  const _FavoritesErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.gray,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          MovieLogButton(
            width: 220,
            label: '다시 시도',
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class _FavoriteMovieCard extends StatelessWidget {
  const _FavoriteMovieCard({required this.movie, required this.onTap});

  final TmdbMovieDto movie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final path = movie.posterPath;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Material(
        color: AppColors.warmWhite,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.statCardBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 64,
                    height: 92,
                    child: path == null
                        ? const ColoredBox(
                            color: AppColors.statCardBackground,
                            child: Icon(Icons.movie_outlined),
                          )
                        : Image.network(
                            'https://image.tmdb.org/t/p/w185$path',
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const ColoredBox(
                              color: AppColors.statCardBackground,
                              child: Icon(Icons.broken_image_outlined),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'TMDB 영화 ID로 연결합니다.',
                        style: TextStyle(color: AppColors.gray, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '즐겨찾기한 영화',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
