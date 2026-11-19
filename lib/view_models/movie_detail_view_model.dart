import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/rating_request.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';

enum SubmitStatus { idle, submitting, success, error }

class MovieDetailViewModel extends ChangeNotifier {
  MovieDetailViewModel(this._ratingService, this.memberId, this.movie);
  final RatingApiService _ratingService;
  final int? memberId; // 학습용 현재 회원. 로그인 인증은 아닙니다.
  final TmdbMovieDto movie;
  SubmitStatus submitStatus = SubmitStatus.idle;
  String? submitMessage;
  bool _disposed = false;

  Future<void> createRating({required int score, String? comment}) async { //별점 생성
    final id = memberId;
    if (id == null) {
      submitStatus = SubmitStatus.error;
      submitMessage = '먼저 회원가입을 완료해 주세요.';
      notifyListeners();
      return;
    }

    if (submitStatus == SubmitStatus.submitting) return; //중복 요청 방지

    submitStatus = SubmitStatus.submitting;
    submitMessage = null;
    notifyListeners();

    try { //서버에 평점 등록 요청
      await _ratingService.createRating(
        memberId: id,
        request: CreateRatingRequest(
          movieId: movie.id,
          score: score,
          comment: comment,
        ),
      );
      if (_disposed) return;
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      if (_disposed) return;
      submitStatus = SubmitStatus.error;
      submitMessage = _ratingService.writeErrorMessage(error);
    }
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
