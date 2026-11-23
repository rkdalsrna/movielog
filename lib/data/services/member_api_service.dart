import 'package:dio/dio.dart';

import '../models/member_info.dart';

class MemberApiService {
  MemberApiService(this._authDio);

  final Dio _authDio;

  Future<MemberInfo> fetchMe() async {
    final response = await _authDio.get('/v7/members/me'); //내 회원 정보를 조회
    return parseMemberInfo(response.data);
  }

  Future<MemberInfo> updateNickname(String nickname) async {
    final response = await _authDio.patch(
      '/v7/members/me',
      data: {'nickname': nickname}, //닉네임을 수정
    );
    return parseMemberInfo(response.data);
  }
}
