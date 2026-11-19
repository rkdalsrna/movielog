import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_error.dart';
import '../data/models/rating_dto.dart';
import '../data/models/rating_request.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import 'auth_view_model.dart';

enum SubmitStatus { idle, submitting, success, error }

class MovieDetailViewModel extends ChangeNotifier {
  MovieDetailViewModel(this._ratingService, this._auth, this.movie);
  final RatingApiService _ratingService;
  final AuthViewModel _auth;
  final TmdbMovieDto movie;
  RatingDto? currentRating;
  SubmitStatus submitStatus = SubmitStatus.idle;
  String? submitMessage;
  bool _disposed = false;

  Future<void> createRating({required int score, String? comment}) async { //별점 생성
    if (submitStatus == SubmitStatus.submitting) return; //중복 요청 방지

    submitStatus = SubmitStatus.submitting;
    submitMessage = null;
    notifyListeners();

    final version = _auth.sessionVersion;
    try { //서버에 평점 등록 요청
      final created = await _ratingService.createRating(
        CreateRatingRequest(
          movieId: movie.id,
          score: score,
          comment: comment,
        ),
      );
      if (!_canApply(version)) return;
      currentRating = created;
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      await _handleDioError(error, version);
    }
    if (!_disposed) notifyListeners();
  }

  Future<void> updateRating({required int score, String? comment}) async {
    final rating = currentRating;
    if (rating == null || submitStatus == SubmitStatus.submitting) return;

    final version = _auth.sessionVersion;
    submitStatus = SubmitStatus.submitting;
    submitMessage = null;
    notifyListeners();
    try {
      final updated = await _ratingService.updateRating(
        ratingId: rating.ratingId,
        score: score,
        comment: comment,
      );
      if (!_canApply(version)) return;
      currentRating = updated;
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      await _handleDioError(error, version);
    }
    if (!_disposed) notifyListeners();
  }

  Future<void> deleteRating() async {
    final rating = currentRating;
    if (rating == null || submitStatus == SubmitStatus.submitting) return;

    final version = _auth.sessionVersion;
    submitStatus = SubmitStatus.submitting;
    submitMessage = null;
    notifyListeners();
    try {
      await _ratingService.deleteRating(rating.ratingId);
      if (!_canApply(version)) return;
      currentRating = null;
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      await _handleDioError(error, version);
    }
    if (!_disposed) notifyListeners();
  }

  bool _canApply(int version) {
    return !_disposed &&
        version == _auth.sessionVersion &&
        _auth.status == AuthStatus.signedIn;
  }

  Future<void> _handleDioError(DioException error, int version) async {
    if (!_canApply(version)) return;
    final code = apiErrorCode(error);
    if (code == 'AUTH401_2' ||
        code == 'AUTH401_3' ||
        code == 'AUTH401_4') {
      await _auth.expireSession();
      return;
    }
    submitStatus = SubmitStatus.error;
    submitMessage = switch (code) {
      'RATING403_1' => '본인이 작성한 평점만 변경할 수 있어요.',
      'RATING409_1' => '이미 이 영화에 평점을 남겼어요.',
      'RATING404_1' => '평점 정보를 찾을 수 없어요.',
      _ => _ratingService.writeErrorMessage(error),
    };
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
