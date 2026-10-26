import 'package:dio/dio.dart';
import 'package:movielog/data/models/tmdb_genre_dto.dart';
import 'package:movielog/data/models/tmdb_movie_page.dart';

//TMDB API에서 영화와 장르 데이터를 조회
class TmdbMovieService {
  TmdbMovieService(this._dio);
  final Dio _dio;

  //인기 영화 조회
  Future<TmdbMoviePageDto> fetchPopular({int page = 1}) async {
    final response = await _dio.get(
      '/movie/popular',
      queryParameters: {'language': 'ko-KR', 'page': page},
    );
    //JSON 응답을 영화 페이지 객체로 변환
    return TmdbMoviePageDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  //영화 목록 조회, 장르 조건 전달
  Future<TmdbMoviePageDto> discoverMovies({
    required int page,
    int? genreId,
  }) async {
    final response = await _dio.get(
      '/discover/movie',
      queryParameters: {
        'language': 'ko-KR',
        'page': page,
        'sort_by': 'popularity.desc',
        'include_adult': false,
        'include_video': false,
        //장르를 선택한 경우에만 검색 조건에 포함
        if (genreId != null) 'with_genres': genreId,
      },
    );
    //JSON 응답을 영화 페이지 객체로 변환
    return TmdbMoviePageDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  //장르 목록 조회
  Future<List<TmdbGenreDto>> fetchGenres() async {
    final response = await _dio.get(
      '/genre/movie/list',
      queryParameters: {'language': 'ko'},
    );
    final data = response.data as Map<String, dynamic>;
    final genres = data['genres'] as List<dynamic>? ?? const [];
    return genres
        .map((item) => TmdbGenreDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
