import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_error.dart';
import '../data/models/login_models.dart';
import '../data/models/member_info.dart';
import '../data/services/auth_api_service.dart';
import '../data/services/member_api_service.dart';
import '../data/storage/token_storage.dart';

enum AuthStatus {
  initializing,
  signedOut,
  authenticating,
  signedIn,
  retryRequired,
}

enum MemberLoadStatus { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._authApi, this._memberApi, this._storage); //생성자

  //의존성 주입
  final AuthApiService _authApi; //로그인 API 호출
  final TokenStorage _storage; //내 회원 정보 조회
  final MemberApiService _memberApi; //JWT 저장, 조회, 삭제

  AuthStatus status = AuthStatus.initializing;
  MemberLoadStatus memberStatus = MemberLoadStatus.idle;
  MemberInfo? member;
  String? message;

  //버전관리
  int _sessionVersion = 0;
  int get sessionVersion => _sessionVersion;

  bool sessionExpired = false; //세션 만료 여부
  bool _disposed = false; //ViewModel 종료 여부
  bool storageCleanupInProgress = false; //토큰 삭제 작업 진행 여부
  Future<void>? _tokenWrite; //현재 진행 중인 토큰 저장 작업

  Future<void> login(String email, String password) async {
    if (_disposed ||
        storageCleanupInProgress ||
        status == AuthStatus.authenticating) {
      return; //중복 방지 실행
    }

    //로그인 요청 중인 상태로 변경하고 기존 회원 정보를 초기화
    status = AuthStatus.authenticating;
    member = null;
    memberStatus = MemberLoadStatus.idle;
    sessionExpired = false;
    message = null;
    final version = ++_sessionVersion;
    _notify();

    try {
      final result = await _authApi.login(  //로그인 API 요청
        LoginRequest(email: email, password: password),
      );
      if (!_isCurrent(version)) return; //현재 버전 아니면 종료

      //액세스 토큰 저장
      final writing = _storage.saveAccessToken(result.accessToken);
      _tokenWrite = writing;

      try {
        await writing; //토큰 저장이 완료될 때까지 기다림
      } finally {
        if (identical(_tokenWrite, writing)) _tokenWrite = null; //작업 끝나면 초기화
        //identical()은 두 변수가 정확히 동일한 객체를 참조하는지 확인
      }

      if (!_isCurrent(version)) return;

      status = AuthStatus.signedIn; //토큰 저장 성공하면 로그인 상태로 변경

    } on DioException catch (error) {
      if (!_isCurrent(version)) return;

      status = AuthStatus.signedOut;
      message = apiErrorCode(error) == 'AUTH401_1'
          ? '이메일 또는 비밀번호를 확인해 주세요.'
          : '로그인 요청에 실패했어요. 잠시 후 다시 시도해 주세요.';
    } catch (_) {
      if (!_isCurrent(version)) return;
      status = AuthStatus.signedOut;
      message = '로그인 정보를 안전하게 저장하지 못했어요.';
    }
    _notify();
  }

  //불필요한 API 요청을 방지
  Future<void> loadMember({bool force = false}) async {
    if (status != AuthStatus.signedIn) return; //로그인하지 않으면 종료
    if (memberStatus == MemberLoadStatus.loading) return; //이미 조회 중이면 종료
    if (member != null && !force) return; //회원 정보가 존재하면 종료

    final version = _sessionVersion;
    memberStatus = MemberLoadStatus.loading;
    _notify();

    try {
      final me = await _memberApi.fetchMe(); //현재 로그인한 회원의 정보를 가져옴

      if (version != _sessionVersion) return;

      member = me; //조회한 회원 정보를 저장
      memberStatus = MemberLoadStatus.success; //조회 성공
    } on DioException catch (error) {
      if (version != _sessionVersion) return;
      final code = apiErrorCode(error);

      if (code == 'AUTH401_2' ||
          code == 'AUTH401_3' ||
          code == 'AUTH401_4') {
        // 세션 만료 시 signedOut으로 바뀌고 Router가 로그인 화면으로 이동
        await _clearCurrentSession();
        return;
      }
      // 네트워크 실패 시 로그아웃하지 않고 다시 시도할 수 있게 함
      memberStatus = MemberLoadStatus.error;
      message = '내 정보를 불러오지 못했어요.';
    }
    _notify();
  }

  // 프로필 수정 성공 응답으로 메모리의 내 정보를 교체함
  void updateMember(MemberInfo updated) {
    if (_disposed || status != AuthStatus.signedIn) return;
    member = updated; //회원 정보 교체
    _notify();
  }

  // 인증 만료 삭제
  Future<void> expireSession() => _clearCurrentSession(expired: true);

  // 사용자 요청 삭제
  Future<void> logout() => _clearCurrentSession(expired: false);

  void consumeSessionExpired() { //세션 만료 안내가 반복적으로 표시되는 것을 방지
    sessionExpired = false; //세션 만료 여부
  }

  Future<void> restoreSession() async { //자동 로그인
    if (storageCleanupInProgress || _disposed) return; //저장소 삭제 작업 중 || ViewModel 종료
    final version = ++_sessionVersion;

    status = AuthStatus.initializing;
    message = null;
    member = null;
    memberStatus = MemberLoadStatus.idle;
    _notify();

    try {
      final token = await _storage.readAccessToken(); //저장된 액세스 토큰 조회
      if (!_isCurrent(version)) return;

      if (token == null || token.isEmpty) { //토큰 없으면 로그아웃 상태처리
        status = AuthStatus.signedOut;
      } else {
        final verifiedMember = await _memberApi.fetchMe(); //회원 정보 조회

        if (!_isCurrent(version)) return;

        member = verifiedMember;
        memberStatus = MemberLoadStatus.success;
        status = AuthStatus.signedIn;
      }

    } on DioException catch (error) {
      if (!_isCurrent(version)) return;
      final code = apiErrorCode(error);
      if (code == 'AUTH401_2' ||
          code == 'AUTH401_3' ||
          code == 'AUTH401_4') {

        await _clearCurrentSession(expired: true);
        return;
      }

      status = AuthStatus.retryRequired;
      message = '로그인 상태를 확인하지 못했어요. 다시 시도해 주세요.';
    } catch (_) {
      if (!_isCurrent(version)) return;
      status = AuthStatus.retryRequired;
      message = '인증 저장소를 읽지 못했어요. 다시 시도해 주세요.';
    }
    if (_isCurrent(version)) _notify();
  }

  bool _isCurrent(int version) {
    return !_disposed && version == _sessionVersion; //ViewModel이 종료되지 않음 && 버전이 동일한지 확인
  }

  Future<void> _clearCurrentSession({bool expired = true}) async { //인증 정보 삭제
    if (_disposed || storageCleanupInProgress) return; //중복 실행 방지

    final version = ++_sessionVersion;
    storageCleanupInProgress = true;

    member = null;
    memberStatus = MemberLoadStatus.idle;
    sessionExpired = expired;
    status = AuthStatus.signedOut;
    message = null;
    _notify();

    try {
      // 진행 중인 토큰 저장을 기다린 뒤 삭제
      try {
        await _tokenWrite;
      } catch (_) {
        // 저장에 실패했더라도 기존 토큰 삭제는 계속 시도
      }
      await _storage.deleteAccessToken();
    } catch (_) {
      if (_isCurrent(version)) {
        message = '저장된 인증 정보를 지우지 못했어요. 앱 재실행 전에 저장소 상태를 확인해 주세요.';
      }
    } finally {
      storageCleanupInProgress = false;
      if (_isCurrent(version)) _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    ++_sessionVersion;
    super.dispose();
  }
}
