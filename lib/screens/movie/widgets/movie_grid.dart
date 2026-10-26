import 'package:flutter/material.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/screens/movie/widgets/movie_grid_card.dart';

class MovieGrid extends StatelessWidget {
  const MovieGrid({
    super.key,
    required this.movies,
    required this.genreNames,
    required this.onMoviePressed,
  });

  final List<TmdbMovieDto> movies;
  final Map<int, String> genreNames;
  final ValueChanged<TmdbMovieDto> onMoviePressed;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(15, 8, 15, 24),
      itemCount: movies.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
        mainAxisExtent: 316.5,
      ),
      itemBuilder: (context, index) {
        final movie = movies[index];

        return MovieGridCard(
          movie: movie,
          genreNames: genreNames,
          onTap: () => onMoviePressed(movie),
        );
      },
    );
  }
}
