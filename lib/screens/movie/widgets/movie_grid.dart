import 'package:flutter/material.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/screens/movie/widgets/movie_grid_card.dart';

class MovieGrid extends StatelessWidget {
  const MovieGrid({
    super.key,
    required this.movies,
    required this.genreNames,
    required this.onMoviePressed,
    this.footer,
  });

  final List<TmdbMovieDto> movies;
  final Map<int, String> genreNames;
  final ValueChanged<TmdbMovieDto> onMoviePressed;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      //영화가 적어도 당겨서 새로고침 가능
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(15, 8, 15, 24),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              final movie = movies[index];
              return MovieGridCard(
                movie: movie,
                genreNames: genreNames,
                onTap: () => onMoviePressed(movie),
              );
            }, childCount: movies.length),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 24,
              mainAxisExtent: 316.5,
            ),
          ),
        ),
        if (footer != null) SliverToBoxAdapter(child: footer),
      ],
    );
  }
}
