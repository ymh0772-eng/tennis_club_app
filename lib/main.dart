// 파일명: lib/main.dart
// 작성일: 2025-11-30
// 작성자: 명화님
// 설명: 테니스 클럽 앱의 진입점 및 기본 화면 골격 (Day 1)

import 'package:flutter/material.dart';

// 1. [함수] 프로그램 시작점 (Engine Start)
void main() {
  runApp(const MyApp());
}

// 2. [위젯] 앱 전체를 설정하는 클래스 (Ship Configuration)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 오른쪽 위 'Debug' 리본 없애기
      title: '테니스 클럽',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen, // 테니스장 잔디색 테마
      ),
      home: const FirstScreen(), // 첫 화면으로 FirstScreen을 지정
    );
  }
}

// 3. [위젯] 실제 사용자에게 보여질 첫 번째 화면 (Main Deck)
class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 3-1. 상단 바 (App Bar)
      appBar: AppBar(
        title: const Text('명화님의 테니스 클럽'),
        centerTitle: true, // 제목 가운데 정렬
        backgroundColor: Colors.lightGreen,
      ),
      // 3-2. 본문 (Body)
      body: const Center(
        child: Text(
          'Day 1: 기초 공사 완료\nGitHub 연동 준비 끝!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}