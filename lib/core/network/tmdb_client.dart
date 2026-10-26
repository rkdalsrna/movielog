import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movielog/core/config/tmdb_config.dart';
import 'package:movielog/core/network/tmdb_logging_interceptor.dart';

//TMDB 요청에 사용할 공통 통신 설정 생성
Dio createTmdbClient() { //API 통신에 사용할 Dio를 만듦
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.themoviedb.org/3',
      connectTimeout: const Duration(seconds: 10), //연결을 맺는 데 허용되는 최대 시간
      receiveTimeout: const Duration(seconds: 10), //응답 데이터를 수신할 때 허용되는 대기 시간
      //모든 요청에 인증 토큰을 포함
      headers: {
        'Authorization': 'Bearer ${TmdbConfig.accessToken}',
        'accept': 'application/json',
      },
    ),
  );

  //디버그 모드에서만 API 로그 기록
  if (kDebugMode) {
    dio.interceptors.add(TmdbLoggingInterceptor());
  }

  return dio;
}