// [Day 17] 실시간 데이터 스트림
// 파일명: screens/realtime_list.dart

import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class RealtimeMemberStart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 1. [키워드: StreamBuilder] 데이터의 '강물(Stream)'을 지켜보는 위젯
    // 서버에서 데이터가 추가되면 즉시 builder가 다시 실행됨
    return StreamBuilder(
      // stream: FirebaseFirestore.instance.collection('members').snapshots(),
      stream: null, // (예제용 null)
      builder: (context, snapshot) {
        // 2. [상태 확인] 데이터가 오는 중인지, 에러인지, 도착했는지 확인
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // 로딩 중
        }
        
        // 3. [UI 렌더링] 도착한 데이터로 리스트 그리기
        // final docs = snapshot.data!.docs;
        return ListView(
          children: [
            // for (var doc in docs) Text(doc['name'])
            Text("서버 데이터가 여기에 표시됩니다.")
          ],
        );
      },
    );
  }
}