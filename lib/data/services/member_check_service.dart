import 'package:dio/dio.dart';

import '../models/check_result.dart';

class MemberCheckService {
  MemberCheckService(this._dio); //Dio를 전달받아 저장
  final Dio _dio;

  Future<bool> checkNickname(String nickname) async { //닉네임 중복 확인 요청
    final encoded = Uri.encodeComponent(nickname.trim()); //앞 뒤 공백 제거랑 URL에 사용할 수 있게 인코딩
    final response = await _dio.get('/v5/members/nickname/$encoded'); //get 요청 보냄
    return CheckResult.fromJson(response.data as Map<String, dynamic>).available; // JSON 응답을 Dart 객체로 변환 후 사용 가능 여부 반환

  }

  Future<bool> checkEmail(String email) async { //이메일 중복 확인 요청
    final encoded = Uri.encodeComponent(email.trim()); //앞 뒤 공백 제거랑 URL에 사용할 수 있게 인코딩
    final response = await _dio.get('/v5/members/email/$encoded'); // get 요청 보냄
    return CheckResult.fromJson(response.data as Map<String, dynamic>).available; // JSON 응답을 Dart 객체로 변환 후 사용 가능 여부 반환
  }
}
