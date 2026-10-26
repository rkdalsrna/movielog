import 'package:movielog/data/mock_movies.dart';
import 'package:movielog/models/movie.dart';

// 영화 목록 요청 결과를 테스트하기 위한 모드
enum MovieLoadMode { success, empty, failure }

// 영화 목록 요청 실패를 표현하는 사용자 정의 예외
class MovieLoadException implements Exception {
  const MovieLoadException(this.message);

  final String message;
}

class FakeMovieService {
  const FakeMovieService();

  Future<List<Movie>> fetchMovies({
    // 모드를 전달하지 않으면 성공 결과 사용
    MovieLoadMode mode = MovieLoadMode.success,
  }) async {
    // 네트워크 요청 상황을 표현하는 1초 지연
    await Future<void>.delayed(const Duration(seconds: 1));

    // TODO(5주차 유저별 평점 조회 API): Mock 데이터를 실제 API 응답으로 교체
    return switch (mode) {
      // 성공 시 기존 Mock 영화 목록 반환
      MovieLoadMode.success => movies,
      // 빈 결과 테스트 시 빈 영화 목록 반환
      MovieLoadMode.empty => const <Movie>[],
      // 실패 테스트 시 사용자 정의 예외 전달
      MovieLoadMode.failure => throw const MovieLoadException(
        '영화를 불러오지 못했습니다.',
      ),
    };
  }
}
