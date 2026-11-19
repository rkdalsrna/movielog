import 'package:dio/dio.dart';

//에러 코드 받아오기
String? apiErrorCode(DioException error) {
  final data = error.response?.data; //서버가 반환한 응답 Body를 가져오기
  if (data is! Map<String, dynamic>) return null; //Map 형태가 아니라면 null을 반환하고 종료
  final code = data['code']; //code라는 Key에 해당하는 값 가져오기
  return code is String ? code : null;
}

//에러 메세지 받아오기
String? apiErrorMessage(DioException error) {
  final data = error.response?.data;
  if (data is! Map<String, dynamic>) return null;
  final message = data['message'];
  return message is String ? message : null;
}