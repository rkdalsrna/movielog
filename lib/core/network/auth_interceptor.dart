import 'package:dio/dio.dart';

import '../../data/storage/token_storage.dart';

//Dio로 API 요청을 보낼 때 인증이 필요한 API에 자동으로 JWT를 추가
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);

  final TokenStorage _storage;

  // 보호 요청(JWT를 붙일 요청)인지 판단합니다.
  bool _isProtected(RequestOptions options) {
    // MovieLog 서버가 아닌 곳(TMDB 등)에는 JWT를 붙이지 않습니다.
    if (options.uri.host != 'workbook.devnoco.com') return false;
    final path = options.uri.path;
    final method = options.method.toUpperCase();

    // 로그인·회원가입·중복 확인은 보호 요청이 아닙니다.
    final w8Protected = path == '/v8/members/me' ||
        path == '/v8/ratings' ||
        path.startsWith('/v8/ratings/');

    // 즐겨찾기 등록·목록 조회·여부 조회·해제
    final favorites = (path == '/v8/favorites' &&
            (method == 'GET' || method == 'POST')) ||
        (RegExp(r'^/v8/favorites/[1-9]\d*$').hasMatch(path) &&
            (method == 'GET' || method == 'DELETE'));

    // 영화 기록 저장(Challenge에서만 사용)
    final movieRecord = path == '/v8/movie-records' && method == 'POST';

    return w8Protected || favorites || movieRecord;
  }

  @override
  Future<void> onRequest(
    RequestOptions options, //URL, Header, Body 등 요청 정보
    RequestInterceptorHandler handler, //요청을 진행하거나 중단하는 객체
  ) async {
    if (!_isProtected(options)) {
      handler.next(options);
      return;
    }

    options.headers.remove('Authorization'); //기존 Authorization 헤더를 삭제

    try {
      final token = await _storage.readAccessToken(); //토큰 불러오기

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token'; //Authorization 헤더에 추가해
      }

      handler.next(options);
    } catch (_) {
      // 서버의 401 응답과 기기 저장소 실패를 서로 다른 오류로 구분합니다.
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          error: StateError('인증 저장소를 읽지 못했습니다.'),
        ),
      );
    }
  }
}
