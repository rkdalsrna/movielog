import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/create_member_request.dart';
import '../data/services/sign_up_service.dart';

enum CheckStatus { idle, checking, available, duplicated, error }
enum SubmitStatus { idle, submitting, success, error }

class SignUpViewModel extends ChangeNotifier {
  SignUpViewModel(this._service);
  final SignUpService _service;

  SubmitStatus submitStatus = SubmitStatus.idle;
  int? createdMemberId; // 가입 성공 응답에서 읽은 실제 ID입니다.
  String? passwordErrorText;
  String? snackbarMessage;

  //닉네임
  CheckStatus nicknameCheckStatus = CheckStatus.idle;
  String? nicknameErrorText; //닉네임 입력창에 표시할 에러 메시지
  String? _duplicatedNickname; //중복이라고 확인된 닉네임
  String _currentNickname = ''; //사용자가 입력하고 있는 닉네임
  int _requestVersion = 0; //중복 요청 방지를 위한 요청 버전

  //이메일
  CheckStatus emailCheckStatus = CheckStatus.idle;
  String? emailErrorText; // 이메일 입력창에 표시할 에러 메시지
  String? _duplicatedEmail; // 중복이라고 확인된 이메일
  String _currentEmail = ''; // 사용자가 입력하고 있는 이메일
  int _emailRequestVersion = 0; // 닉네임과 별도로 이메일 요청의 최신 여부를 확인

  bool _disposed = false; //dispose()가 호출되었는지 여부, 종료되었는지 확인

  bool get canCheckNickname =>
      nicknameCheckStatus != CheckStatus.checking && //중복 확인 중이 아니고
          nicknameCheckStatus != CheckStatus.duplicated; //중복된 상태가 아닐 때 true

  void onNicknameChanged(String value) { //사용자가 닉네임 입력값을 변경할 때 실행
    final trimmed = value.trim();
    _currentNickname = trimmed;
    snackbarMessage = null;
    if (submitStatus == SubmitStatus.error) submitStatus = SubmitStatus.idle;
    _requestVersion++; // 이전 요청의 응답을 무효화합니다.
    if (_duplicatedNickname != null && trimmed == _duplicatedNickname) { //중복된 닉네임을 저장한 적이 있는지 && 현재 입력값이 저장된 중복 닉네임과 같은지
      nicknameCheckStatus = CheckStatus.duplicated; //중복 상태로 변경
      nicknameErrorText = '이미 사용 중인 닉네임입니다.';
    } else { //저장된 중복 닉네임과 다른 경우
      nicknameCheckStatus = CheckStatus.idle; //중복 확인 상태 초기화
      nicknameErrorText = null; //에러 메세지 제거
    }
    if (!_disposed) notifyListeners(); //종료되지 않았으면 상태 변경 알림
  }

  //실제 닉네임 중복 확인
  Future<void> checkNickname(String value) async {
    final requested = value.trim();
    if (requested.isEmpty || requested != _currentNickname || //비어있는지, 현재 입력된 닉네임과 다른지, 중복 확인 중이거나 중복된 상태인지
        !canCheckNickname) return; //종료

    final version = ++_requestVersion; //요청 버전 증가
    nicknameCheckStatus = CheckStatus.checking; //중복 확인 중 상태로 변경
    nicknameErrorText = null; //에러 메세지 제거
    notifyListeners(); //상태 변경 알림

    try {
      final available = await _service.checkNickname(requested); // 서버에 닉네임 중복 확인을 요청하고 사용 가능 여부를 기다림
      if (_disposed || version != _requestVersion ||
          _currentNickname != requested) return; // 종료됐거나 최신 요청이 아니거나 입력값이 바뀌었다면 응답을 무시
      nicknameCheckStatus = available // 사용 가능 여부에 따라 확인 상태를 설정
          ? CheckStatus.available : CheckStatus.duplicated;
      nicknameErrorText = available // 사용 가능하면 에러 메시지를 지우고 중복이면 안내 메시지를 설정
          ? null : '이미 사용 중인 닉네임입니다.';
      if (!available) _duplicatedNickname = requested; //중복된 닉네임이라면 _duplicatedNickname에 저장
    } on DioException {
      if (_disposed || version != _requestVersion ||
          _currentNickname != requested) return; // 통신 오류가 발생해도 종료됐거나 현재 입력에 대한 최신 요청이 아니면 무시
      nicknameCheckStatus = CheckStatus.error; // 요청 실패 상태와 재시도 안내 메시지를 설정
      nicknameErrorText = '중복 확인에 실패했습니다. 다시 시도해 주세요.';
    }
    if (!_disposed && version == _requestVersion) notifyListeners(); //종료되지 않고 요청이 최신이면 상태 변경 알림
  }


  bool get canCheckEmail =>
      emailCheckStatus != CheckStatus.checking && // 중복 확인 중이 아니고
      emailCheckStatus != CheckStatus.duplicated; // 중복된 상태가 아닐 때 true

  void onEmailChanged(String value) { // 사용자가 이메일 입력값을 변경할 때 실행
    final trimmed = value.trim();
    _currentEmail = trimmed;
    snackbarMessage = null;
    if (submitStatus == SubmitStatus.error) submitStatus = SubmitStatus.idle;
    _emailRequestVersion++; // 이전 이메일 요청의 응답을 무효화
    if (_duplicatedEmail != null && trimmed == _duplicatedEmail) {
      emailCheckStatus = CheckStatus.duplicated;
      emailErrorText = '이미 사용 중인 이메일입니다.';
    } else { // 저장된 중복 이메일과 다른 경우 확인 상태 초기화
      emailCheckStatus = CheckStatus.idle;
      emailErrorText = null;
    }
    if (!_disposed) notifyListeners();
  }

  // 실제 이메일 중복 확인
  Future<void> checkEmail(String value) async {
    final requested = value.trim();
    if (requested.isEmpty ||
        requested != _currentEmail ||
        !canCheckEmail) return;

    final version = ++_emailRequestVersion; // 이번 이메일 요청 번호 저장
    emailCheckStatus = CheckStatus.checking;
    emailErrorText = null;
    notifyListeners();

    try {
      final available = await _service.checkEmail(requested);
      // 종료됐거나 최신 이메일 요청이 아니거나 입력값이 바뀌었다면 무시
      if (_disposed ||
          version != _emailRequestVersion ||
          _currentEmail != requested) return;
      emailCheckStatus = available
          ? CheckStatus.available : CheckStatus.duplicated;
      emailErrorText = available
          ? null : '이미 사용 중인 이메일입니다.';
      if (!available) _duplicatedEmail = requested; // 중복된 이메일 저장
    } on DioException {
      // 이전 요청의 오류가 현재 이메일 상태를 덮어쓰지 않도록 확인
      if (_disposed ||
          version != _emailRequestVersion ||
          _currentEmail != requested) return;
      emailCheckStatus = CheckStatus.error;
      emailErrorText = '중복 확인에 실패했습니다. 다시 시도해 주세요.';
    }
    // 종료되지 않고 이메일 요청이 최신이면 상태 변경 알림
    if (!_disposed && version == _emailRequestVersion) notifyListeners();
  }

  void onPasswordChanged() {
    passwordErrorText = null;
    snackbarMessage = null;
    if (submitStatus == SubmitStatus.error) submitStatus = SubmitStatus.idle;
    notifyListeners();
  }

  Future<void> submit(CreateMemberRequest request) async {
    if (submitStatus == SubmitStatus.submitting) return;
    submitStatus = SubmitStatus.submitting;
    createdMemberId = null;
    passwordErrorText = null;
    snackbarMessage = null;
    notifyListeners();

    try {
      final response = await _service.signUp(request);
      final id = response.result?.memberId;
      if (id == null) throw StateError('회원가입 결과에 memberId가 없습니다.');
      createdMemberId = id;
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      submitStatus = SubmitStatus.error;
      final message = _service.writeSignUpErrorMessage(error);
      if (error.response?.statusCode == 400 && message.contains('비밀번호')) {
        passwordErrorText = message;
      } else {
        snackbarMessage = message;
      }
    } on StateError {
      submitStatus = SubmitStatus.error;
      snackbarMessage =
          '가입 결과를 확인하지 못했습니다. 새 요청 전에 서버 상태를 확인해 주세요.';
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    _emailRequestVersion++;
    super.dispose();
  }
}
