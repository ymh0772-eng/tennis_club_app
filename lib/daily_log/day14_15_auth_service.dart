// [Day 14-15] 파이어베이스 인증 서비스
// 파일명: services/auth_service.dart

// (가상의 코드: firebase_auth 패키지 필요)
// import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // 1. [키워드: Instance] 파이어베이스 인증 도구 가져오기
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  // 2. [기능: Sign In] 이메일/비번으로 로그인
  Future<String?> signIn(String email, String password) async {
    try {
      // 3. [동작: Await] 서버 응답을 기다림 (비동기 처리)
      // await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "Success";
    } catch (e) {
      // 4. 실패 시 에러 메시지 반환
      return e.toString();
    }
  }

  // 5. [기능: Sign Out] 로그아웃
  Future<void> signOut() async {
    // await _auth.signOut();
  }
}