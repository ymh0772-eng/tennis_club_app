// 파일명: lib/main.dart
// 작성일: 2025-11-30
// 작성자: 명화님
// 설명: 버튼을 누르면 출석 인원이 올라가는 기능 구현 (Day 2)

import 'package:flutter/material.dart';

void main() {
  runApp(const TennisApp());
}

class TennisApp extends StatelessWidget {
  const TennisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '테니스 클럽',
      theme: ThemeData(primarySwatch: Colors.lightGreen),
      home: const AttendanceScreen(), // 여기를 교체했습니다.
    );
  }
}

// 1. [위젯] 상태(데이터)를 가질 수 있는 위젯 (엔진이 있는 배)
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

// 2. [State] 실제 데이터와 화면을 관리하는 클래스 (조타실)
class _AttendanceScreenState extends State<AttendanceScreen> {
  // 변수 선언: 출석 인원 수 (초기값 0명)
  int attendanceCount = 0;

  // 함수: 버튼을 누르면 실행될 동작
  void _addMember() {
    setState(() {
      attendanceCount++; // 숫자를 1 증가시킴
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('테니스 클럽 출석부'),
        backgroundColor: Colors.lightGreen,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 수직 중앙 정렬
          children: <Widget>[
            const Text(
              '현재 출석 인원:',
              style: TextStyle(fontSize: 20),
            ),
            // 변수(attendanceCount)를 화면에 표시
            Text(
              '$attendanceCount 명',
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
          ],
        ),
      ),
      // 우측 하단 + 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: _addMember, // 버튼을 누르면 _addMember 함수 실행
        tooltip: '출석 체크',
        child: const Icon(Icons.add),
      ),
    );
  }
}