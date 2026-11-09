import 'package:dio/dio.dart';

import '../models/check_result.dart';
import '../models/common_response.dart';
import '../models/create_member_request.dart';
import '../models/sign_up_models.dart';

class SignUpService {
  SignUpService(this._dio); //Dio를 전달받아 저장
  final Dio _dio;

  Future<bool> checkNickname(String nickname) async { //닉네임 중복 확인 요청
    final encoded = Uri.encodeComponent(nickname.trim()); //앞 뒤 공백 제거랑 URL에 사용할 수 있게 인코딩
    final response = await _dio.get('/v6/members/nickname/$encoded'); //get 요청 보냄 , v6으로 변경
    return CheckResult.fromJson(response.data as Map<String, dynamic>).available; // JSON 응답을 Dart 객체로 변환 후 사용 가능 여부 반환
  }

  Future<bool> checkEmail(String email) async { //이메일 중복 확인 요청
    final encoded = Uri.encodeComponent(email.trim()); //앞 뒤 공백 제거랑 URL에 사용할 수 있게 인코딩
    final response = await _dio.get('/v6/members/email/$encoded'); // get 요청 보냄 , v6으로 변경
    return CheckResult.fromJson(response.data as Map<String, dynamic>).available; // JSON 응답을 Dart 객체로 변환 후 사용 가능 여부 반환
  }

// 기존 SignUpService 클래스(구 MemberCheckService) 내부에 추가합니다.
  Future<CommonResponse<SignUpResult>> signUp( //회원가입 요청
      CreateMemberRequest request,
      ) async {
    final response = await _dio.post(
      '/v6/members',
      data: request.toJson(), //CreateMemberRequest.toJson()이 반환한 JSON body를 전달
    );

    return CommonResponse<SignUpResult>.fromJson( //서버 응답 JSON을 공통 응답 객체로 변환
      response.data as Map<String, dynamic>,
          (value) => SignUpResult.fromJson(value as Map<String, dynamic>),
    );
  }

  String writeSignUpErrorMessage(DioException error) {
    final data = error.response?.data;
    final common = data is Map<String, dynamic>
        ? CommonResponse<Object?>.fromJson(data, (value) => value)
        : null;
    return common?.message ?? '회원가입에 실패했습니다. 잠시 후 다시 시도해 주세요.';
  }
}
