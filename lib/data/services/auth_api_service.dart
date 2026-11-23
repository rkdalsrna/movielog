import 'package:dio/dio.dart';

import '../models/common_response.dart';
import '../models/login_models.dart';

class AuthApiService {
  AuthApiService(this._dio);

  final Dio _dio;

  Future<LoginResult> login(LoginRequest request) async {
    final response = await _dio.post( //로그인 API 요청 post
      '/v8/auth/login',
      data: request.toJson(),
    );
    final data = response.data;

    if (data is! Map<String, dynamic>) { //JSON 객체에 해당하는 Map 형태인지 확인
      throw StateError('로그인 응답 형식이 올바르지 않습니다.');
    }

    final common = CommonResponse<LoginResult>.fromJson( // 공통 응답 및 내부 result 파싱
      data,
      (value) => LoginResult.fromJson(value as Map<String, dynamic>),
    );
    final result = common.result; // 실제 로그인 결과 추출

    if (result == null) {
      throw StateError('로그인 result가 없습니다.');
    }
    return result;
  }
}
