import 'package:dio/dio.dart';

import '../../data/storage/token_storage.dart';
import 'auth_interceptor.dart';

Dio createMovieLogClient() { //일반 Dio 생성
  return Dio(_movieLogOptions());
}

Dio createAuthMovieLogClient(TokenStorage storage) { //인증용 Dio 생성
  final dio = Dio(_movieLogOptions());
  dio.interceptors.add(AuthInterceptor(storage)); //AuthInterceptor를 등록, 자동으로 헤더에 추가
  return dio;
}

BaseOptions _movieLogOptions() {
  return BaseOptions(
    baseUrl: 'https://workbook.devnoco.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  );
}
