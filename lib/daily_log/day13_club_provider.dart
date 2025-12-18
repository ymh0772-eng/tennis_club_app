// [Day 13] 상태 관리 프로바이더
// 파일명: providers/club_provider.dart

import 'package:flutter/material.dart';
import '../models/member_model.dart'; // Day 12의 모델 임포트

// 1. [키워드: ChangeNotifier] 데이터 변경 시 "나 바뀌었어!"라고 방송하는 기능
class ClubProvider with ChangeNotifier {
  List<Member> _members = [];

  // 2. [기능: Getter] 외부에서 리스트를 읽기만 가능하게 함 (보안)
  List<Member> get members => _members;

  void addMember(Member newMember) {
    _members.add(newMember);
    
    // 3. [동작: Notify] 리스트가 변했음을 UI에 알림 -> 화면 자동 갱신
    notifyListeners(); 
  }

  void removeMember(String id) {
    _members.removeWhere((item) => item.id == id);
    
    // 4. 데이터 삭제 후 구독자(UI)들에게 알림
    notifyListeners();
  }
}