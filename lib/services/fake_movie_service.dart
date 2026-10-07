import 'package:movielog/data/mock_movies.dart';
import 'package:movielog/models/movie.dart';

class FakeMovieService {
  const FakeMovieService();

  Future<List<Movie>> fetchMovies() async {
    // 네트워크 요청 상황을 표현하는 1초 지연
    await Future<void>.delayed(const Duration(seconds: 1));

    // 기존 Mock 영화 목록 반환
    return movies;
  }
}
