class CheckResult {
  const CheckResult({required this.available});

  // 닉네임 또는 이메일의 사용 가능 여부
  final bool available;

  // 서버의 JSON 응답으로 중복 확인 결과 객체를 생성
  factory CheckResult.fromJson(Map<String, dynamic> json) {
    // available 값을 bool로 캐스팅하며 null이거나 다른 타입이면 오류 발생
    return CheckResult(available: json['available'] as bool);
  }
}
