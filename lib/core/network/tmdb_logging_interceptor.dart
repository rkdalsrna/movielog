import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class TmdbLoggingInterceptor extends Interceptor { //API 요청과 응답을 확인하기 위한 로그 담당
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    //인증 토큰이 로그에 노출되지 않도록 가림
    final maskedHeaders = Map<String, dynamic>.from(options.headers);
    if (maskedHeaders.containsKey('Authorization')) {
      maskedHeaders['Authorization'] = 'Bearer ***';
    }
    debugPrint('[TMDB 요청] ${options.method} ${options.uri}');
    debugPrint('[TMDB 요청 Header] $maskedHeaders');
    if (options.queryParameters.isNotEmpty) {
      debugPrint('[TMDB 요청 Query] ${options.queryParameters}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('[TMDB 응답] ${response.statusCode} ${response.requestOptions.uri}');
    debugPrint('[TMDB 응답 Body] ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    //인증 실패 등 오류 응답의 상태 코드 확인
    debugPrint('[TMDB 오류 Status] ${err.response?.statusCode ?? '응답 없음'}');
    debugPrint('[TMDB 오류] ${err.requestOptions.uri}');
    debugPrint('[TMDB 오류 내용] ${err.message}');
    handler.next(err);
  }
}