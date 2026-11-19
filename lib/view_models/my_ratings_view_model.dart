import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_error.dart';
import '../data/models/rating_with_movie.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import '../data/models/movie.dart';
import 'auth_view_model.dart';

enum MyRatingsLoadStatus { idle, loading, success, empty, error }

class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(
    this._service,
    this._movieService,
    this._auth,
    this.memberId,
  );

  final RatingApiService _service;
  final TmdbMovieService _movieService;
  final AuthViewModel _auth;
  final int memberId;
  final Map<int, Movie?> _movieCache = {};
  int _requestVersion = 0;
  bool _disposed = false;

  List<RatingWithMovie> ratings = const [];
  MyRatingsLoadStatus status = MyRatingsLoadStatus.idle;
  String? message;
  String? refreshWarning;
  final Set<int> selectedRatingIds = {};
  bool isSelectionMode = false;
  bool isDeletingSelected = false;

  void startSelection() { //선택 모드를 활성화
    isSelectionMode = true;
    notifyListeners();
  }

  void cancelSelection() { //선택 모드를 종료 후 선택한 것들 지움
    isSelectionMode = false;
    selectedRatingIds.clear();
    notifyListeners();
  }

  void toggleRatingSelection(int ratingId) {
    if (!selectedRatingIds.add(ratingId)) {
      selectedRatingIds.remove(ratingId);
    }
    notifyListeners();
  }

  Future<void> load() async { //평점 목록 조회
    final version = ++_requestVersion;
    status = MyRatingsLoadStatus.loading;
    message = null;
    notifyListeners();

    try {
      final rawRatings = await _service.fetchMyRatings(memberId);
      if (_disposed || version != _requestVersion) return;
      final entries = <RatingWithMovie>[];
      var missingMovies = 0;
      // 같은 movieId는 캐시를 사용하고, 영화 조회 실패가 평점 목록을 지우지 않음
      for (final rating in rawRatings) {
        if (_disposed || version != _requestVersion) return;
        if (!_movieCache.containsKey(rating.movieId)) {
          try {
            final movie = await _movieService.findMovieById(rating.movieId);
            if (_disposed || version != _requestVersion) return;
            _movieCache[rating.movieId] = movie;
          } on DioException {
            // 일시적 네트워크 실패는 캐시하지 않고 다음 로딩에서 재시도
          }
        }
        final movie = _movieCache[rating.movieId];
        if (movie == null) missingMovies++;
        entries.add(RatingWithMovie(rating: rating, movie: movie)); //하나의 객체로 묶어서 리스트에 추가
      }
      if (_disposed || version != _requestVersion) return;
      ratings = entries;
      status = entries.isEmpty
          ? MyRatingsLoadStatus.empty : MyRatingsLoadStatus.success;
      if (missingMovies > 0) {
        message = '일부 영화 정보를 가져오지 못해 제목·포스터를 대신 표시합니다.';
      }
    } on DioException catch (error) {
      if (_disposed || version != _requestVersion) return;
      status = MyRatingsLoadStatus.error;
      message = writeMyRatingsErrorMessage(error);
    }
    if (!_disposed && version == _requestVersion) notifyListeners();
  }

  Future<void> _refreshAfterWrite() async {
    await load(); // 6주차 load()는 GET 실패를 status=error로 기록합니다.
    if (status == MyRatingsLoadStatus.error) {
      refreshWarning =
          '저장은 완료됐지만 목록을 불러오지 못했습니다. 조회만 다시 시도해 주세요.';
      notifyListeners();
    } else {
      refreshWarning = null;
    }
  }

  Future<void> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    final sessionVersion = _auth.sessionVersion;
    try {
      final updated = await _service.updateRating(
        ratingId: ratingId,
        score: score,
        comment: comment,
      );
      if (!_canApplySession(sessionVersion)) return;
      ratings = [
        for (final entry in ratings)
          if (entry.rating.ratingId == ratingId)
            RatingWithMovie(rating: updated, movie: entry.movie)
          else
            entry,
      ];
    } on DioException catch (error) {
      if (!await _handleWriteError(error, sessionVersion)) return;
      final errorMessage = message!;
      message = errorMessage;
      notifyListeners();
      if (_service.shouldRefreshAfterRatingError(error)) await load();
      message = errorMessage;
      notifyListeners();
      rethrow; // 쓰기 실패일 때만 Dialog가 실패로 처리합니다.
    }
    await _refreshAfterWrite(); // GET 실패는 저장 실패로 다시 던지지 않습니다.
  }

  Future<void> deleteRating(int ratingId) async {
    final sessionVersion = _auth.sessionVersion;
    try {
      await _service.deleteRating(ratingId);
      if (!_canApplySession(sessionVersion)) return;
      ratings = ratings
          .where((entry) => entry.rating.ratingId != ratingId)
          .toList();
    } on DioException catch (error) {
      if (!await _handleWriteError(error, sessionVersion)) return;
      final errorMessage = message!;
      message = errorMessage;
      notifyListeners();
      if (_service.shouldRefreshAfterRatingError(error)) await load();
      message = errorMessage;
      notifyListeners();
      rethrow;
    }
    await _refreshAfterWrite();
  }

  Future<void> deleteSelectedRatings() async {
    if (isDeletingSelected || selectedRatingIds.isEmpty) return;
    isDeletingSelected = true;
    notifyListeners();
    var failed = 0;
    final sessionVersion = _auth.sessionVersion;
    try {
      for (final ratingId in selectedRatingIds.toList()) {
        try {
          await _service.deleteRating(ratingId);
          selectedRatingIds.remove(ratingId);
        } on DioException catch (error) {
          if (!await _handleWriteError(error, sessionVersion)) return;
          failed++;
          // 실패한 항목은 선택 상태를 유지합니다.
        }
      }
    } finally {
      isDeletingSelected = false;
      if (!_disposed) {
        notifyListeners(); // 예상하지 못한 오류에도 로딩을 해제합니다.
      }
    }
    await _refreshAfterWrite(); // GET 실패는 삭제 성공 여부와 분리합니다.
    if (failed > 0) {
      message = '$failed개 항목을 삭제하지 못했습니다. 선택된 항목을 다시 확인해 주세요.';
      notifyListeners();
    }
  }

  bool _canApplySession(int version) {
    return !_disposed &&
        version == _auth.sessionVersion &&
        _auth.status == AuthStatus.signedIn;
  }

  Future<bool> _handleWriteError(
    DioException error,
    int sessionVersion,
  ) async {
    if (!_canApplySession(sessionVersion)) return false;
    final code = apiErrorCode(error);
    if (code == 'AUTH401_2' ||
        code == 'AUTH401_3' ||
        code == 'AUTH401_4') {
      await _auth.expireSession();
      return false;
    }
    message = switch (code) {
      'RATING403_1' => '본인이 작성한 평점만 변경할 수 있어요.',
      'RATING409_1' => '이미 이 영화에 평점을 남겼어요.',
      'RATING404_1' => '평점 정보를 찾을 수 없어요.',
      _ => _service.writeErrorMessage(error),
    };
    return true;
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}
