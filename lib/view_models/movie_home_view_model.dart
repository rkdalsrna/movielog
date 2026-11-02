import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';

enum MovieHomeLoadStatus { idle, loading, success, empty, error }

//홈 화면의 인기 영화와 요청 상태를 관리
class MovieHomeViewModel extends ChangeNotifier {
  MovieHomeViewModel(this._service);
  final TmdbMovieService _service;

  List<TmdbMovieDto> popularMovies = const [];
  MovieHomeLoadStatus status = MovieHomeLoadStatus.idle;
  String? message;
  bool _disposed = false;
  int _requestVersion = 0;

  //인기 영화를 조회하고 최대 5개 저장
  Future<void> loadPopular() async {
    final version = ++_requestVersion;
    //로딩 상태를 화면에 전달
    status = MovieHomeLoadStatus.loading;
    notifyListeners();

    try {
      final page = await _service.fetchPopular(); //TMDB 인기 영화 API를 호출하고 응답을 기다림
      if (_disposed || version != _requestVersion) return; //이미 필요 없어진 API 응답이 ViewModel의 상태를 변경하지 못하도록 방지하는 코드
      popularMovies = page.results.take(5).toList(); //인기 영화 목록에서 상위 5개만 저장
      status = popularMovies.isEmpty
          ? MovieHomeLoadStatus.empty //비어있으면
          : MovieHomeLoadStatus.success; //하나 이상 있으면
    } on DioException { //Dio에서 발생한 네트워크 관련 예외를 처리
      if (_disposed || version != _requestVersion) return; //_disposed와 요청 버전을 검사
      //통신 실패 시 오류 상태와 안내 문구 설정
      status = MovieHomeLoadStatus.error;
      message = '인기 영화를 불러오지 못했어요.';
    }

    //조회 결과를 구독 중인 화면에 전달, _disposed가 아닌 경우 + 요청 버전이 동일한 경우
    if (!_disposed && version == _requestVersion) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}
