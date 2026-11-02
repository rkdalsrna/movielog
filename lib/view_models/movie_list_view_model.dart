import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:movielog/data/models/tmdb_genre_dto.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';

//영화 목록 요청 상태를 구분
enum MovieListLoadStatus {
  idle, //요청 전
  loading, //요청 중
  success, //영화 조회 성공
  empty, //조회된 영화 없음
  error, //요청 실패
}

//영화 목록 화면에 필요한 데이터와 상태를 관리
class MovieListViewModel extends ChangeNotifier {
  MovieListViewModel(this._service);
  final TmdbMovieService _service;

  List<TmdbMovieDto> movies = const [];
  List<TmdbGenreDto> genres = const [];
  Set<String> selectedGenreNames = const {};
  MovieListLoadStatus status = MovieListLoadStatus.idle;
  String? message;

  //이전 요청 결과가 최신 데이터를 덮어쓰지 않도록 요청 번호 관리
  int _requestVersion = 0;
  //ViewModel 해제 여부를 확인
  bool _disposed = false;

  //여러 페이지에서 중복을 제외한 영화 최대 30개 조회
  Future<List<TmdbMovieDto>> fetchUpToThirtyMovies({
    List<int> genreIds = const [],
  }) async {
    final byId = <int, TmdbMovieDto>{};
    var pageNumber = 1; //장르 변경 시 첫 페이지부터 조회
    var hasNextPage = true;

    while (byId.length < 30 && hasNextPage) {
      final page = await _service.discoverMovies(
        page: pageNumber, //현재 페이지 번호 전달
        genreIds: genreIds, //선택한 장르 ID 목록 전달
      );

      for (final movie in page.results) {
        //영화 ID를 키로 사용해 중복 제거
        byId[movie.id] = movie;
        if (byId.length == 30) break; //최대 30개 영화 조회
      }

      //마지막 페이지이거나 결과가 없으면 추가 요청 종료
      hasNextPage = pageNumber < page.totalPages && page.results.isNotEmpty;
      pageNumber++; //다음 페이지 번호로 변경
    }

    return byId.values.take(30).toList(); //중복 제거한 영화를 최대 30개 반환
  }

  //장르와 초기 영화 목록을 조회
  Future<void> loadInitial() async {
    final version = ++_requestVersion;
    //로딩 상태를 화면에 전달
    message = null;
    status = MovieListLoadStatus.loading;
    notifyListeners();

    try {
      final loadedGenres = await _service.fetchGenres();
      if (_disposed || version != _requestVersion) return;
      genres = loadedGenres;
      //선택한 장르 이름을 TMDB ID로 변환
      final genreIds = genres
          .where((genre) => selectedGenreNames.contains(genre.name))
          .map((genre) => genre.id)
          .toList();
      final discovered = await fetchUpToThirtyMovies(genreIds: genreIds);

      //해제된 ViewModel이거나 이전 요청이면 결과 무시
      if (_disposed || version != _requestVersion) return;
      movies = discovered;
      status = movies.isEmpty
          ? MovieListLoadStatus.empty
          : MovieListLoadStatus.success;
    } on DioException {
      //해제된 ViewModel이거나 이전 요청이면 결과 무시
      if (_disposed || version != _requestVersion) return;
      status = MovieListLoadStatus.error;
      message = '영화를 불러오지 못했어요. 다시 시도해 주세요.';
    }

    //최신 요청의 완료 상태를 화면에 전달
    if (!_disposed && version == _requestVersion) notifyListeners();
  }

  //선택 장르를 저장하고 page 1부터 다시 조회
  Future<void> selectGenres(Set<String> names) async {
    selectedGenreNames = Set.unmodifiable(names);
    await loadInitial();
  }

  @override
  void dispose() {
    //진행 중인 요청 결과를 무효화
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}
