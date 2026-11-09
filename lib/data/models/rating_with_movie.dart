import '../../models/movie.dart';
import 'rating_dto.dart';

class RatingWithMovie {
  const RatingWithMovie({
    required this.rating,
    this.movie,
  });

  final RatingDto rating;
  final Movie? movie; // TMDB에서 찾지 못했으면 null입니다.
}
