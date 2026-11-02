import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/core/config/tmdb_config.dart';
import 'package:movielog/core/network/tmdb_client.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  //명시적으로 실행할 때 실제 TMDB 서버의 인증과 로그를 확인
  test('Popular API 실제 응답과 인증 헤더 마스킹 확인', () async {
    await dotenv.load(fileName: '.env');
    final token = TmdbConfig.accessToken;
    if (token.isEmpty) fail('TMDB_ACCESS_TOKEN이 설정되지 않았습니다.');

    //Flutter 테스트의 가짜 HTTP 응답 대신 실제 통신 사용
    final previousOverrides = HttpOverrides.current;
    HttpOverrides.global = null;
    final previousDebugPrint = debugPrint;
    final logs = <String>[];
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) logs.add(message);
    };
    final client = createTmdbClient();
    int? statusCode;
    client.interceptors.add(InterceptorsWrapper(
      onResponse: (response, handler) {
        statusCode = response.statusCode;
        handler.next(response);
      },
    ));

    try {
      final page = await TmdbMovieService(client).fetchPopular();
      //토큰을 포함할 수 있는 원문 로그는 출력하지 않음
      if (logs.any((line) => line.contains(token))) {
        fail('인증 토큰이 로그에 노출되었습니다.');
      }
      expect(statusCode, 200);
      expect(logs.any((line) => line.contains('Authorization: Bearer ***')), isTrue);
      expect(logs.any((line) => line.contains('[TMDB 응답] 200')), isTrue);
      expect(page.results, isNotEmpty);
      previousDebugPrint('[검증 완료] Authorization: Bearer ***, Status: 200');
    } on DioException catch (error) {
      fail('Popular API 요청 실패: Status ${error.response?.statusCode ?? '응답 없음'}');
    } finally {
      client.close(force: true);
      debugPrint = previousDebugPrint;
      HttpOverrides.global = previousOverrides;
    }
  }, skip: !const bool.fromEnvironment('TMDB_LIVE_CHECK'));
}
