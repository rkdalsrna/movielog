import 'package:flutter/foundation.dart';

class LearningMemberSession extends ChangeNotifier {
  int? memberId;

  void setMemberId(int id) { //사용자의 회원 ID를 저장
    memberId = id;
    notifyListeners();
  }

  void clear() { //저장된 회원 ID를 초기화
    memberId = null;
    notifyListeners();
  }
}
