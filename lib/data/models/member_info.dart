import 'common_response.dart';

class MemberInfo {
  const MemberInfo({
    required this.email,
    required this.nickname,
    required this.createdAt,
  });

  final String email;
  final String nickname;
  final DateTime createdAt;

  factory MemberInfo.fromJson(Map<String, dynamic> json) { //JSON을 객체로 변환
    return MemberInfo(
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

MemberInfo parseMemberInfo(Object? data) { //서버의 전체 응답을 처리
  if (data is! Map<String, dynamic>) { //JSON 객체 형태인지 확인
    throw StateError('내 정보 응답 형식이 올바르지 않습니다.');
  }
  final common = CommonResponse<MemberInfo>.fromJson(
    data,
    (value) => MemberInfo.fromJson(value as Map<String, dynamic>),
  );
  final member = common.result;
  if (member == null) {
    throw StateError('내 정보 result가 없습니다.');
  }
  return member;
}
