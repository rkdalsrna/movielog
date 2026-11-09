import 'package:dio/dio.dart';
import 'package:movielog/models/movie.dart';
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
    return TmdbMoviePageDto.fromJson(response.data as Map<String, dynamic>);
  }

  //영화 목록 조회, 장르 조건 전달
  Future<TmdbMoviePageDto> discoverMovies({
    required int page,
    List<int> genreIds = const [],
  }) async {
    final response = await _dio.get(
      '/discover/movie', //Discover API 호출
      queryParameters: {
        'language': 'ko-KR',
        'page': page, //ViewModel에서 전달한 페이지 번호 사용
        'sort_by': 'popularity.desc', //인기순 조회
        'include_adult': false,
        'include_video': false,
        //장르를 선택한 경우에만 검색 조건에 포함
        if (genreIds.isNotEmpty) 'with_genres': genreIds.join('|'),
      },
    );
    //JSON 응답을 영화 페이지 객체로 변환 ,API 응답을 DTO로 변환
    return TmdbMoviePageDto.fromJson(response.data as Map<String, dynamic>);
  }

  //영화 ID로 상세 정보 조회
  Future<Movie> fetchMovieDetail(int movieId) async {
    final response = await _dio.get(
      '/movie/$movieId',
      queryParameters: {'language': 'ko-KR'},
    );
    final data = response.data as Map<String, dynamic>; // 서버 응답 JSON을 Map 형태로 변환
    final date = data['release_date'] as String? ?? ''; // 개봉일 추출
    final posterPath = data['poster_path'] as String?; // 포스터 이미지 경로 추출
    final genres = data['genres'] as List<dynamic>? ?? const []; // 장르 목록 추출

    // JSON 데이터를 Movie 객체로 변환하여 반환
    return Movie(
      id: (data['id'] as num).toInt(), // 영화 ID를 정수형으로 변환
      title: data['title'] as String? ?? '제목 없음', // 영화 제목 추출
      genre: genres
          .map((item) => (item as Map<String, dynamic>)['name'] as String)
          .join(' · '), // 장르 이름만 추출하여 ' · '으로 연결
      year: date.length >= 4 ? int.tryParse(date.substring(0, 4)) ?? 0 : 0, // 개봉일에서 연도 4자리 추출 후 정수로 변환
      runningTime: (data['runtime'] as num? ?? 0).toInt(), // 상영 시간을 정수형으로 변환
      posterAsset: posterPath == null
          ? ''
          : 'https://image.tmdb.org/t/p/w500$posterPath', // 포스터 경로를 TMDB 이미지 URL로 변환
      //상세 화면의 별점은 5점 기준으로 변환
      rating: (data['vote_average'] as num? ?? 0).toDouble() / 2,
      synopsis: data['overview'] as String? ?? '', // 영화 줄거리 추출
    );
  }

  // 영화가 없으면 null을 반환하고 다른 통신 오류는 호출한 곳으로 전달
  Future<Movie?> findMovieById(int movieId) async {
    try {
      return await fetchMovieDetail(movieId);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return null;
      rethrow;
    }
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
