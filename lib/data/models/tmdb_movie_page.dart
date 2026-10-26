import 'package:movielog/data/models/tmdb_movie_dto.dart';
//TMDB 영화 목록 페이지 데이터
class TmdbMoviePageDto {
  const TmdbMoviePageDto({
    required this.page, //현재 페이지 번호
    required this.results, //영화 목록
    required this.totalPages, //전체 페이지 수
    required this.totalResults, //전체 영화 수
  });

  final int page;
  final List<TmdbMovieDto> results;
  final int totalPages;
  final int totalResults;
  //JSON 응답을 객체로 변환
  factory TmdbMoviePageDto.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'] as List<dynamic>? ?? const [];

    return TmdbMoviePageDto(
      page: (json['page'] as num).toInt(),
      results: rawResults
          .map(
            (item) => TmdbMovieDto.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList(),
      totalPages: (json['total_pages'] as num).toInt(),
      totalResults: (json['total_results'] as num).toInt(),
    );
  }
}
