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

  //인기 영화를 조회하고 최대 5개 저장
  Future<void> loadPopular() async {
    //로딩 상태를 화면에 전달
    status = MovieHomeLoadStatus.loading;
    notifyListeners();

    try {
      final page = await _service.fetchPopular();
      popularMovies = page.results.take(5).toList();
      status = popularMovies.isEmpty
          ? MovieHomeLoadStatus.empty
          : MovieHomeLoadStatus.success;
    } on DioException {
      //통신 실패 시 오류 상태와 안내 문구 설정
      status = MovieHomeLoadStatus.error;
      message = '인기 영화를 불러오지 못했어요.';
    }

    //조회 결과를 구독 중인 화면에 전달
    notifyListeners();
  }
}
