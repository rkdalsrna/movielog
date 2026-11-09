//공통 응답 Model
class CommonResponse<T> {
  const CommonResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    this.result,
  });

  final bool isSuccess; //성공 여부
  final String code; //처리 결과 code
  final String message; //사용자 안내 메세지
  final T? result; //실제 데이터, API마다 담기는 값이 다르므로 제네릭 T으로 씀

  factory CommonResponse.fromJson( //JSON을 Dart 객체로 변환
      Map<String, dynamic> json,
      T Function(Object? value) parseResult,
      ) {
    final rawResult = json['result'];
    return CommonResponse<T>(
      isSuccess: json['isSuccess'] as bool,
      code: json['code'] as String,
      message: json['message'] as String,
      result: rawResult == null ? null : parseResult(rawResult), //데이터가 존재할 때만 변환
    );
  }
}