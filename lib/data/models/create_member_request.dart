//서버에 보낼 회원가입 요청
class CreateMemberRequest {
  const CreateMemberRequest({
    required this.email,
    required this.password,
    required this.nickname,
  });

  final String email;
  final String password;
  final String nickname;

  Map<String, dynamic> toJson() => {
    'email': email.trim(),
    'password': password, //비밀 번호는 trim() 하지 않음
    'nickname': nickname.trim(),
  };
}